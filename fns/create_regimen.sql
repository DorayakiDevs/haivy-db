CREATE OR REPLACE FUNCTION dev.create_regimen(
    p_name text,
    p_level smallint,
    p_description text default '',
    p_is_for_adults boolean default true,
    default_medicines json default null
)
RETURNS uuid AS $$
DECLARE
    v_regimen_id uuid;
    v_medicine_item json;
    v_medicine_id uuid;
    v_total_day smallint;
    v_daily_dosage_schedule json;
BEGIN
    --check user role
    -- if(auth.uid() is null) or not ((select roles from user_details where user_id = auth.uid()) @> array['administrator', 'manager']::role[])
    -- then
    -- raise exception 'You do not have permission to perform this action';
    -- end if;
    select check_roles(array['administrator', 'manager']::role[]);
       

    INSERT INTO regimens (
        name,
        description,
        level,
        is_for_adults
    ) VALUES (
        p_name,
        p_description,
        p_level,
        p_is_for_adults
    ) RETURNING regimen_id INTO v_regimen_id;

    IF default_medicines IS NOT NULL THEN
        FOR v_medicine_item IN SELECT value FROM json_array_elements(default_medicines)
        LOOP
            v_medicine_id := (v_medicine_item ->> 'medicine_id')::uuid;
            if not exists (select 1 from medicines where id = v_medicine_id)
            then
            raise exception 'Medicine id does not exist: %s', v_medicine_id;
            end if;
            v_total_day := (v_medicine_item ->> 'total_day')::smallint;
            v_daily_dosage_schedule := v_medicine_item -> 'daily_dosage_schedule';
            PERFORM public.validate_daily_dosage_schedule(v_daily_dosage_schedule::jsonb); 

            PERFORM dev.add_medicine_into_regimen(
                v_medicine_id,
                v_regimen_id,
                v_total_day,
                v_daily_dosage_schedule
            );
        END LOOP;
    END IF;

    RETURN v_regimen_id;
END;
$$ LANGUAGE plpgsql;