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

> **Note on port 8888:** `refresh-artifacts.sh` bakes `VITE_KEYCLOAK_URL=http://localhost:8888/auth`
> into the admin-ui build at compile time. If you change the exposed port, update that variable
> in the script and rebuild before running `docker compose up --build`.

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

The `fee_engine` database is seeded by a `db-seeder` one-shot service that runs
`psql -f seed.sql` (TRUNCATE + INSERT 6 rules) after fee-engine becomes healthy.
The seeder runs on each `docker compose up` — any rules created during a demo
session are wiped on the next startup. Use `docker compose down -v && docker compose up`
for a guaranteed clean slate.

### Seed rules

| # | Payment type | Scheme | Currency | Fee type | Notes |
|---|---|---|---|---|---|
| 1 | DOMESTIC | FPS | GBP | FLAT | £0.25 flat |
| 2 | INTERNATIONAL | SWIFT | GBP | PERCENTAGE | 1.5%, capped £0.50–£25 |
| 3 | DOMESTIC | CHAPS | GBP | TIERED_SLAB | Fixed-amount slab tiers |
| 4 | INTERNATIONAL | SWIFT | EUR | FREE | Zero-fee EU transfers |
| 5 | DOMESTIC | BACS | GBP | FLAT | £2.00, high-priority |
| 6 | INTERNATIONAL | SWIFT | USD | TIERED_STEP | Progressive %: 3%/2%/1% per bracket |

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `fee-engine` restarting in a loop | DB or Keycloak not yet healthy | Wait; `docker compose logs fee-engine` for details |
| `db-seeder` exits non-zero | Wrong `POSTGRES_PASSWORD` or DB not ready | Check `.env`, run `docker compose logs db-seeder` |
| Login redirects to wrong port | SPA baked with wrong Keycloak URL | Run `./scripts/refresh-artifacts.sh` then `docker compose up --build` |
| `keycloak` stuck unhealthy | Realm import slow on first boot | Increase `start_period` in compose or wait; check `docker compose logs keycloak` |

## Why JARs and dist/ are committed to this repo

This is a demo repository, not a source repository. Pre-built artifacts
(JARs, `dist/`) are committed so that `docker compose up --build` works
immediately after clone — no Maven or Node.js required for the demo itself.
Run `./scripts/refresh-artifacts.sh` only when you want to incorporate
source changes from the sibling repos.
