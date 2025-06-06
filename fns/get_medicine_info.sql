CREATE OR REPLACE FUNCTION get_medication_info(
        med_id uuid
) 
RETURNS JSON AS $$ 
DECLARE
        result json;
BEGIN
        SELECT json_build_object(
                'name', m.name,
                'description', m.description,
                'is_available', m.is_available,
                'consumption_note', m.consumption_note
        ) INTO result
        FROM medicines m
        WHERE m.id = med_id;

        RETURN result;
-- incase error occurs
EXCEPTION
        WHEN OTHERS THEN
        RAISE EXCEPTION 'Something went wrong when trying to view this medicine: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;