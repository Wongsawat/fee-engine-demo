#!/bin/bash
set -e
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
  CREATE USER fee_engine WITH PASSWORD '$POSTGRES_PASSWORD';
  CREATE USER fee_ai     WITH PASSWORD '$POSTGRES_PASSWORD';
  CREATE DATABASE fee_engine       OWNER fee_engine;
  CREATE DATABASE fee_ai_assistant OWNER fee_ai;
EOSQL
