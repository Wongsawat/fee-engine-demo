# Fee Engine Demo

Single-command Docker Compose demo for the fee-engine platform.

## Prerequisites

- Docker Engine 24+ with Compose v2 (`docker compose version`)
- Java 21 + Maven (for `refresh-artifacts.sh`)
- Node.js 22 + npm (for `refresh-artifacts.sh`)
- Sibling repos checked out at the same parent directory:
  - `../fee-engine`
  - `../fee-engine-ai-assistant`
  - `../fee-engine-admin-ui`
- Port **8888** free on the host (port 80 is occupied on most developer laptops; this compose stack maps 8888:80 instead)

## First-time setup

```bash
# 1. Configure secrets
cp .env.example .env
# Edit .env: set ANTHROPIC_AUTH_TOKEN and KEYCLOAK_ADMIN_PASSWORD

# 2. Build artifacts from source
./scripts/refresh-artifacts.sh

# 3. Start the platform
docker compose up --build
```

Open **http://localhost:8888** — login with `demo` / `demo`.

> **Note on port 8888:** `refresh-artifacts.sh` currently bakes
> `VITE_KEYCLOAK_URL=http://localhost` into the admin-ui build. If you change
> the exposed port (or move the demo off `localhost`), edit the script before
> rebuilding so the SPA points at the right issuer.

## Day-to-day commands

| Scenario | Command |
|---|---|
| Start | `docker compose up` |
| Stop | `docker compose down` |
| Wipe all data and reseed | `docker compose down -v && docker compose up` |
| After source code changes | `./scripts/refresh-artifacts.sh && docker compose up --build` |
| View service logs | `docker compose logs -f fee-engine` |

## Services

| URL | Service |
|---|---|
| http://localhost:8888 | Admin UI |
| http://localhost:8888/auth | Keycloak admin console (`admin` / `$KEYCLOAK_ADMIN_PASSWORD`) |
| http://localhost:8888/admin/fee-rules | fee-engine API (requires Bearer token) |
| http://localhost:8888/ai/drafts | AI assistant API (requires Bearer token) |

## Demo credentials

- **App login:** `demo` / `demo`
- **Keycloak admin:** `admin` / `$KEYCLOAK_ADMIN_PASSWORD` (set in `.env`)

## Architecture note

Only port 8888 is exposed to the host. JWT issuer-URI validation **is** enabled
on both backends via `OIDC_ISSUER_URI` — tokens are validated against
`http://localhost:8888/auth/realms/pisp`. `directAccessGrantsEnabled: true` is
set on the `fee-engine-admin-ui` client so the smoke test can obtain a token
via the Resource Owner Password Credentials grant (ROPC). ROPC is a less-secure
OAuth flow — the client receives the user's password directly — and is only
safe here because the demo is localhost-only with a single throwaway demo
user. Do not use this compose configuration in any shared or
internet-accessible environment.

## Seed data

The `fee_engine` database is seeded with 5 demo rules on first boot by a
`db-seeder` one-shot service that runs `psql -f /seed.sql` after fee-engine
becomes healthy. A V8 Flyway migration
(`infra/postgres/migrations/V8__seed_fee_rules.sql`) carries the same seed
data for the source repo's Flyway chain. On every fee-engine restart, the
`db-seeder` re-runs `TRUNCATE fee_rules CASCADE;` followed by the inserts,
so any user-created rules are wiped — this is expected for a demo.

## Why JARs and dist/ are committed to this repo

This is a demo repository, not a source repository. Pre-built artifacts
(JARs, `dist/`) are committed so that `docker compose up --build` works
immediately after clone — no Maven or Node.js required for the demo itself.
Run `./scripts/refresh-artifacts.sh` only when you want to incorporate
source changes from the sibling repos.
