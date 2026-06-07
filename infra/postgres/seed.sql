-- Wipe on every boot (SPRING_SQL_INIT_MODE=always). User-created rules do not survive restart.
TRUNCATE fee_rules CASCADE;

INSERT INTO fee_rules (
    id, payment_type, scheme, charge_bearer, account_identification,
    charge_type, fee_type, flat_amount, percentage, tiers,
    currency, destination_country, min_fee, max_fee,
    active, priority, version, created_by, updated_by,
    created_at, updated_at
) VALUES

-- Rule 1: Flat fee — domestic FPS
(gen_random_uuid(), 'DOMESTIC', 'FPS', 'BorneByDebtor', NULL,
 'CHARGEType001', 'FLAT', 0.25, NULL, NULL,
 'GBP', NULL, NULL, NULL,
 TRUE, 0, 0, 'seed', 'seed',
 NOW(), NOW()),

-- Rule 2: Percentage fee — international SWIFT (with min/max cap)
(gen_random_uuid(), 'INTERNATIONAL', 'SWIFT', 'BorneByDebtor', NULL,
 'CHARGEType001', 'PERCENTAGE', NULL, 0.015, NULL,
 'GBP', NULL, 0.50, 25.00,
 TRUE, 0, 0, 'seed', 'seed',
 NOW(), NOW()),

-- Rule 3: Tiered fee — domestic CHAPS
(gen_random_uuid(), 'DOMESTIC', 'CHAPS', 'BorneByDebtor', NULL,
 'CHARGEType001', 'TIERED', NULL, NULL,
 '[{"min":0,"max":1000,"amount":0.10},{"min":1000,"max":10000,"amount":0.05},{"min":10000,"max":999999999,"amount":0.02}]'::jsonb,
 'GBP', NULL, NULL, NULL,
 TRUE, 0, 0, 'seed', 'seed',
 NOW(), NOW()),

-- Rule 4: Free — international EUR (EU transfers)
(gen_random_uuid(), 'INTERNATIONAL', 'SWIFT', 'BorneByDebtor', NULL,
 'CHARGEType001', 'FREE', NULL, NULL, NULL,
 'EUR', NULL, NULL, NULL,
 TRUE, 0, 0, 'seed', 'seed',
 NOW(), NOW()),

-- Rule 5: High-value flat fee — domestic BACS
(gen_random_uuid(), 'DOMESTIC', 'BACS', 'BorneByDebtor', NULL,
 'CHARGEType001', 'FLAT', 2.00, NULL, NULL,
 'GBP', NULL, NULL, NULL,
 TRUE, 10, 0, 'seed', 'seed',
 NOW(), NOW());
