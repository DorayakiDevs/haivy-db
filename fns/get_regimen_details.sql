CREATE OR REPLACE FUNCTION dev.get_regimen_details(
    p_regimen_id uuid
)
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT to_json(array_agg(details))
        FROM (
            SELECT 
                r.*,
                rd.*,
                m.name AS medicine_name
            FROM regimens r
            JOIN regimen_details rd ON rd.regimen_id = r.regimen_id
            JOIN Medicines m ON rd.medicine_id = m.id
            WHERE rd.regimen_id = p_regimen_id
        ) AS details
    );
END;
$$ LANGUAGE plpgsql;
