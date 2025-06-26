BEGIN;

-- Insert into regimens table and capture auto-generated regimen_id
WITH inserted_regimens AS (
  INSERT INTO regimens (name, create_date, description, level, is_for_adults, is_available)
  VALUES
    ('Pain Relief Plan', '2025-06-20', 'For managing chronic pain conditions.', 1, true, true),
    ('Allergy Relief Protocol', '2025-06-21', 'Treatment for seasonal allergies.', 1, true, true),
    ('HIV Maintenance Therapy', '2025-06-22', 'Maintenance for HIV-positive patients.', 2, true, false),
    ('Anti-Infection Course', '2025-06-23', 'Short-term antibiotic treatment.', 1, true, true),
    ('Vitamin Support Plan', '2025-06-24', 'Nutritional supplementation for deficiencies.', 1, true, true)
  RETURNING regimen_id
)

-- Insert into regimen_details using the auto-generated regimen_id values
INSERT INTO regimen_details (regimen_id, medicine_id, total_day, daily_dosage_schedule)
SELECT
  regimen_id,
  medicine_id,
  total_day,
  daily_dosage_schedule
FROM (
  -- Pain Relief Plan: 2 medicines
  SELECT (SELECT regimen_id FROM inserted_regimens LIMIT 1 OFFSET 0) AS regimen_id, '05d5c1df-1e7b-42bb-99aa-df90e68f0d53'::uuid AS medicine_id, 7 AS total_day, '[
    {"time_of_day": "morning", "amount": 1, "note": "Take with food"},
    {"time_of_day": "evening", "amount": 1, "note": "Take with water"}
  ]'::jsonb
   AS daily_dosage_schedule
  UNION ALL
  SELECT (SELECT regimen_id FROM inserted_regimens LIMIT 1 OFFSET 0), '7b5ede9e-13f5-4d4a-bb07-3b89ec74ee1f'::uuid, 7, '[
    {"time_of_day": "morning", "amount": 2, "note": "Take with milk"},
    {"time_of_day": "night", "amount": 2, "note": "Before bed"}
  ]'::jsonb
  
  -- Allergy Relief Protocol: 1 medicine
  UNION ALL
  SELECT (SELECT regimen_id FROM inserted_regimens LIMIT 1 OFFSET 1), '651ca627-d7b9-4783-ab38-4d67ecd9d081'::uuid, 5, '[
    {"time_of_day": "morning", "amount": 1, "note": "Take with water"}
  ]'::jsonb
  
  -- HIV Maintenance Therapy: 3 medicines
  UNION ALL
  SELECT (SELECT regimen_id FROM inserted_regimens LIMIT 1 OFFSET 2), '28e48e8a-d2f9-403e-9af7-b6824b6c948d'::uuid, 30, '[
    {"time_of_day": "morning", "amount": 1, "note": "Take with food"},
    {"time_of_day": "evening", "amount": 1, "note": "Drink plenty of water"}
  ]'::jsonb
  
  UNION ALL
  SELECT (SELECT regimen_id FROM inserted_regimens LIMIT 1 OFFSET 2), '306b2ac7-d7a1-4f85-be94-49233ce9c377'::uuid, 30, '[
    {"time_of_day": "morning", "amount": 1, "note": "Take consistently"}
  ]'::jsonb
  
  UNION ALL
  SELECT (SELECT regimen_id FROM inserted_regimens LIMIT 1 OFFSET 2), '7cd16919-34d0-4756-82c5-563e4c30a9dd'::uuid, 30, '[
    {"time_of_day": "morning", "amount": 1, "note": "Test for HLA-B*5701 required"}
  ]'::jsonb
  
  -- Anti-Infection Course: 2 medicines
  UNION ALL
  SELECT (SELECT regimen_id FROM inserted_regimens LIMIT 1 OFFSET 3), 'f6fb2d2c-4fe4-4165-a5cb-fa1c9bb9b5c9'::uuid, 7, '[
    {"time_of_day": "morning", "amount": 1, "note": "Take with water"},
    {"time_of_day": "evening", "amount": 1, "note": "Avoid dairy"}
  ]'::jsonb
  
  UNION ALL
  SELECT (SELECT regimen_id FROM inserted_regimens LIMIT 1 OFFSET 3), '3995b00e-e527-4b07-bc4d-9f5c11aa0434', 7, '[
    {"time_of_day": "morning", "amount": 1, "note": "Take with food"},
    {"time_of_day": "night", "amount": 1, "note": "Complete the course"}
  ]'::jsonb
  
  -- Vitamin Support Plan: 1 medicine
  UNION ALL
  SELECT (SELECT regimen_id FROM inserted_regimens LIMIT 1 OFFSET 4), '6be31f37-c565-4a23-a4f6-3e52909a6a86'::uuid, 14, '[
    {"time_of_day": "morning", "amount": 1, "note": "Take with breakfast"}
  ]'::jsonb
  
) AS details;

COMMIT;