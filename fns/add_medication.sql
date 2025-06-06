CREATE OR REPLACE FUNCTION add_medication(
    med_name varchar,
    med_description text,
    med_availability boolean,
    med_consumption_note text
)
RETURNS VOID AS $$
DECLARE
    temp_user_role role;
BEGIN
    IF (auth.uid() IS NULL) OR NOT ((SELECT roles FROM user_details WHERE user_id = auth.uid()) @> ARRAY['administrator', 'manager']::role[]) THEN
    RAISE EXCEPTION 'You do not have permission to perform this action';
    END IF;
    INSERT INTO Medicines (
        name, 
        description, 
        is_available, 
        consumption_note
    )
    VALUES (
        med_name, 
        med_description, 
        med_availability, 
        med_time
    );
    --eror here
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Something went wrong while trying to add medicine: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;