-- DOCUMENTATION ONLY — this file is NOT executed by the demo compose stack.
-- The active seed mechanism is the db-seeder service (see docker-compose.yml),
-- which runs infra/postgres/seed.sql (TRUNCATE + INSERT) after fee-engine is healthy.
--
-- This file documents what a permanent V8 Flyway migration would look like if
-- the seed data were to be incorporated into the fee-engine source repo's migration
-- chain instead of a separate seeder container.
--
-- NOTE: ON CONFLICT DO NOTHING without a conflict target would fail against the
-- partial unique index uniq_active_fee_rules (V7). To use this as a real migration,
-- replace with TRUNCATE fee_rules CASCADE; followed by plain INSERT statements.

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

-- Rule 3: Tiered slab fee — domestic CHAPS
(gen_random_uuid(), 'DOMESTIC', 'CHAPS', 'BorneByDebtor', NULL,
 'CHARGEType001', 'TIERED_SLAB', NULL, NULL,
 '[{"min":0,"max":1000,"rateType":"FIXED","amount":0.10},{"min":1000,"max":10000,"rateType":"FIXED","amount":0.05},{"min":10000,"max":999999999,"rateType":"FIXED","amount":0.02}]'::jsonb,
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
 NOW(), NOW()),

-- Rule 6: Tiered step fee — international SWIFT USD (progressive percentage tiers)
(gen_random_uuid(), 'INTERNATIONAL', 'SWIFT', 'BorneByDebtor', NULL,
 'CHARGEType001', 'TIERED_STEP', NULL, NULL,
 '[{"min":0,"max":10000,"rateType":"PERCENTAGE","percentage":0.03},{"min":10000,"max":50000,"rateType":"PERCENTAGE","percentage":0.02},{"min":50000,"max":999999999,"rateType":"PERCENTAGE","percentage":0.01}]'::jsonb,
 'USD', NULL, NULL, NULL,
 TRUE, 0, 0, 'seed', 'seed',
 NOW(), NOW())
ON CONFLICT DO NOTHING;
