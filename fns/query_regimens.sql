CREATE OR REPLACE FUNCTION dev.query_regimens(
    query text DEFAULT '',
    p_level smallint DEFAULT NULL,
    p_is_for_adults boolean DEFAULT NULL,
    _offset integer DEFAULT 0,
    _limit integer DEFAULT 100
)
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT to_json(array_agg(reg))
        FROM (
            SELECT *
            FROM Regimens r
            WHERE 
                (query = '' OR r.name ILIKE '%' || query || '%' OR r.description ILIKE '%' || query || '%')
                AND (p_level IS NULL OR r.level = p_level)
                AND (p_is_for_adults IS NULL OR r.is_for_adults = p_is_for_adults)
            LIMIT _limit OFFSET _offset
        ) AS reg
    );
END;
$$ LANGUAGE plpgsql;
