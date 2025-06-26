// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'npm:@supabase/supabase-js@2'
import {
  ImageMagick,
  initializeImageMagick,
  MagickFormat
} from "npm:@imagemagick/magick-wasm@0.0.30";
import { AnyARecord } from "node:dns";
import { error } from "node:console";

const wasmBytes = await Deno.readFile(
  new URL(
        "magick.wasm",
        import.meta.resolve("npm:@imagemagick/magick-wasm@0.0.30"),
  ),
);
await initializeImageMagick(
  wasmBytes,
)
Deno.serve(async (req: Request) => {
try{
    const supabaseClient = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    // Create client with Auth context of the user that called the function.
    // This way your row-level-security (RLS) policies are applied.
    {
      global: {
        headers: { Authorization: req.headers.get('Authorization')! },
      },
    }
  );
  //-----------------------------------------
    // Get the session or user object
  const authHeader = req.headers.get('Authorization')!;
  const token = authHeader.replace('Bearer ', '');
  const { data:userToken } = await supabaseClient.auth.getUser(token);
  const user = userToken.user;
  if(user == null){
    return new Response(
      "invalid user",
      {
        status: 401
      }
    )
  };
  console.log(JSON.stringify({user})+ "called updateProfilePicture");
  //-------------------------------------------
  //get the form data and extract it
  const reqData = await req.formData();
  const profileImage = reqData.get("file") as File;
  // in supabase example they wrote
  // const profileImage = reqData.get("file") ^.bytes()^;somehow i am not be able to do so 
  const fullName = reqData.get("full_name");
  const dob = reqData.get("dob");
  //------------------------------------------
  //resize the image
  if(profileImage == null){
    return new Response(
      "Empty image file",
      {
        status: 400
      }
    )
  }
  const imageBuffer = await profileImage.arrayBuffer();
  const imageToBytes = new Uint8Array(imageBuffer);

  const resized = await ImageMagick.read(
    imageToBytes,
    (image): Uint8Array =>{
      image.resize(512, 512);
      return image.write(
        MagickFormat.Png,
        (imageData) => imageData,
      );
    },     
  );
  //----------------------------------------------
  //upload the new picture and information
  if(resized == null){
    return new Response(
      "image parse failed",
      {
        status: 500
      }
    )
  };
  let profile_picture_url;
  const {data: resizedImage, error: uploadError} = await supabaseClient.storage
  .from("user_details")
  .upload(`public/${user.id}.png`, resized, {
                cacheControl: "3600",
                upsert: true,
  });
  if(!uploadError){
    const{data: pictureURL} = await supabaseClient.storage.from("user_details")
    .getPublicUrl(resizedImage.path);
    profile_picture_url = pictureURL.publicUrl;
  }else{
    return new Response(
      "failed to upload picture",
      {
        status: 400
      }
    )
  }
  const updateTheRest: any ={
    user_id: user.id,
    profile_picture: profile_picture_url?.toString(),
  }
  if(fullName !== null && fullName!== ''){
    updateTheRest.full_name = fullName;
  }
  if(dob !== null && dob !== ''){
    updateTheRest.birth_date = dob;
  }
  await supabaseClient.from("user_details")
  .upsert(updateTheRest).select()
  
  //response a success status 200
  return new Response(
    "process executed succesfully",
    {
      status: 200
    }
  );
}catch(e){
  let logMes = (e as DOMException).message
  //throw error code 500
  return new Response(
    'unhandled error: '+ logMes,
    {
      status: 500,
    }
  );
}
});
/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/updateUserProfile' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
