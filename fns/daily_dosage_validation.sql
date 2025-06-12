create or replace function validate_daily_dosage_schedule (p_json_of_dosage_schedule jsonb)
    -- this require the extension pg_jsonschema enabled in our DB, i have enabled it
returns void as
$$
    begin
        if(jsonb_array_length(p_json_of_dosage_schedule)) = 0 then
        raise exception 'Empty json array detected, process terminated: %', SQLERRM;
        end if;
        if not (
            jsonb_matches_schema(               
                '{
                "type": "array",
                "items": {
                        
                        "type": "object",
                        "properties":{
                            "time_of_day":{
                                "type": "string",
                                "enum": ["morning", "noon", "afternoon", "night"]
                            },
                            "amount": {
                                "type": "number"
                            },
                            "note":{
                                "type": "string"
                            }
                        },
                        "required": ["time_of_day", "amount", "note"],
                        "additionalProperties": false                       
                        }
                }'
                ,p_json_of_dosage_schedule
            );
        ) then
        raise exception 'Invalid daily dosage schedule json, please double check';
        end if;     
    end;
$$
language plpgsql;

