create or replace function dev.update_regimen(
    p_regimen_id uuid,
    p_name text default null,
    p_description text default null,
    p_level smallint default null,
    p_is_for_adults boolean default null,
    p_override_medicines json default null
)
returns void as 
$$
declare
    p_medicine_id uuid;
    p_total_day smallint;
    p_daily_dosage_schedule json;
    override_json json;
begin
    --check user role
    -- if(auth.uid() is null) or not ((select roles from user_details where user_id = auth.uid()) @> array['administrator', 'manager']::role[])
    -- then
    -- raise exception 'You do not have permission to perform this action';
    -- end if;
    select check_roles(array['administrator', 'manager']::role[]);
    begin
    --update the table regimens
        update regimens
        set
            name = coalesce(p_name, name),
            description = coalesce(p_description, description),
            level = coalesce(p_level, level),
            is_for_adults = coalesce(p_is_for_adults, is_for_adults)       
        where regimen_id = p_regimen_id;
        --delete the medicine that need to be override
        for override_json in select * from json_array_elements(p_override_medicines)
        loop
            p_medicine_id := override_json ->> 'medicine_id';
            p_total_day := override_json ->> 'total_day'::smallint;
            p_daily_dosage_schedule := override_json -> 'daily_dosage_schedule';
            select validate_daily_dosage_schedule(p_daily_dosage_schedule::jsonb);
            --delete the old medicine
            delete from regimen_details rd
            where rd.regimen_id = p_regimen_id
            and rd.medicine_id = p_medicine_id;
            --insert new information into regimen_details
            select add_medicine_into_regimen(
                p_medicine_id,
                p_total_day,
                p_daily_dosage_schedule
            );
        end loop;
    end;
end;
$$
language plpgsql;