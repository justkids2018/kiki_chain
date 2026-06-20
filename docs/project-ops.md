# Project Operations & Development Guidelines

This document details project-specific operational guidelines and rules that AI agents must follow when developing, updating, and deploying the Kikichain application.

---

## 💾 Database Migrations

### 1. PostgreSQL Compatibility
- The local development and production backend database is **PostgreSQL**.
- All SQL migrations must strictly use PostgreSQL-compatible syntax. 
- **Prohibited MySQL Dialects**:
  - Do NOT use `AUTO_INCREMENT` (use `BIGSERIAL` or `SERIAL` instead).
  - Do NOT use `TINYINT(1)` (use `BOOLEAN` or `SMALLINT` instead).
  - Do NOT use `DATETIME` (use `TIMESTAMP` or `TIMESTAMPTZ` instead).
  - Do NOT use `ON DUPLICATE KEY UPDATE` (use `ON CONFLICT (...) DO UPDATE SET ...` instead).
  - Do NOT specify `ENGINE=InnoDB` or character sets/collations inside the table definition.

### 2. Migration Placement & Sync Rule
Whenever a new database migration is created or updated, it must be synchronized across two directories:
1. **Local Development**: `kiki_server/migrations/`
   - Used for local database setup, testing, and debugging.
2. **Production Deployment**: `scripts/deploy-release/db/migrations/`
   - Used by the automated release workflow (`db-release.sh` called by `step2-deploy.sh`).
   - Must use sequential version numbering (e.g., `005_create_learning_tables.sql`).
   
> [!IMPORTANT]
> If a migration SQL is not added to `scripts/deploy-release/db/migrations/`, it **will be skipped** during production deployment, causing the server backend to fail on startup or crash during database queries.

---

## 📱 Frontend (Flutter & GetX) Development

### 1. Avoid Layout Overflows
- In child/parent container rows containing localized text, always wrap text widgets (e.g., displaying localized strings like `localizations.interactiveLearning`) inside an `Expanded` or `Flexible` widget.
- This prevents horizontal text layouts from overflowing the right boundary under long-translation Locales (such as English) or narrow viewport constraints.

### 2. Localization & i18n
- Never use hardcoded strings for user-visible UI text.
- Always retrieve text via `AppLocalizations.of(context)!` or controller localization delegates.

### 3. Verification & CI Check
Before committing and pushing any frontend modifications:
- Always run `flutter test` to ensure all regression tests pass successfully.
- Run `flutter analyze` to verify code quality.

---

## 🖥️ Local Development Environment Scripts

Project-level local development scripts live under `scripts/local_dev/`.
When a user asks to start, stop, migrate, check status, or view logs for the local development environment, **use these scripts directly** instead of typing ad-hoc commands.

| Script | Purpose | Usage |
|--------|---------|-------|
| `scripts/local_dev/start.sh` | Start local dev env (PostgreSQL + Rust backend + Vue frontend) | `./scripts/local_dev/start.sh` |
| `scripts/local_dev/stop.sh` | Stop all local services | `./scripts/local_dev/stop.sh` |
| `scripts/local_dev/migrate.sh` | Run local DB incremental migrations | `./scripts/local_dev/migrate.sh` |
| `scripts/local_dev/status.sh` | Check service status | `./scripts/local_dev/status.sh` |
| `scripts/local_dev/logs.sh` | View service logs (all / backend / frontend) | `./scripts/local_dev/logs.sh [backend\|frontend]` |

> **Note:** `start.sh` automatically detects running services to avoid double-starting, boots PostgreSQL via Docker, applies local DB migrations, then starts the Rust backend (`cargo run`) and Vue frontend (`npm run dev`).
