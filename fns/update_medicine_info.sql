CREATE OR REPLACE FUNCTION update_medication_info(
    med_id uuid,
    med_name varchar,
    med_description text,
    med_availability boolean,
    med_consumption_note text
)
RETURNS VOID AS $$
DECLARE
    user_role role;
BEGIN
    IF (auth.uid() IS NULL) OR NOT ((SELECT roles FROM user_details WHERE user_id = auth.uid()) @> ARRAY['administrator', 'manager']::role[]) THEN
    RAISE EXCEPTION 'You do not have permission to perform this action';
    END IF;
    UPDATE Medicines
    SET 
        name = med_name,
        description = med_description,
        is_available = med_availability,
        consumption_note = med_consumption_note
    WHERE id = med_id;
--in case something else went wrong
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Something went wrong while trying to update medicine: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;