CREATE OR REPLACE FUNCTION delete_medication(
    med_id uuid
)
RETURNS VOID AS $$
DECLARE
    user_role role;
BEGIN
    IF (auth.uid() IS NULL) OR NOT ((SELECT roles FROM user_details WHERE user_id = auth.uid()) @> ARRAY['administrator', 'manager']::role[]) THEN
    RAISE EXCEPTION 'You do not have permission to perform this action';
    END IF;
    UPDATE Medicines
    SET is_available = FALSE
    WHERE id = med_id;
--in case something else went wrong
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Something went wrong while trying to delete medicine: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;