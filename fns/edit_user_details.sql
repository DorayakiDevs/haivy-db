CREATE OR REPLACE FUNCTION edit_user_details(
  p_user_id uuid,
  p_full_name text,
  p_birth_date date
) 
RETURNS BOOLEAN AS $$
DECLARE
  v_updated_count INTEGER;
BEGIN
  UPDATE user_details
  SET 
    full_name = COALESCE(p_full_name, full_name),
    birth_date = COALESCE(p_birth_date, birth_date)
  WHERE user_id = p_user_id;

  GET DIAGNOSTICS v_updated_count = ROW_COUNT;

  RETURN v_updated_count > 0;
END;
$$ LANGUAGE plpgsql;