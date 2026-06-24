# Kiki Server Database

This directory is the target single source of truth for backend database execution files.

## Structure

```text
kiki_server/database/
├── README.md
├── init.sql
├── migrations/
├── seeds/
└── snapshots/
```

## Runtime Rules

- `init.sql` is the baseline for a brand-new database.
- `migrations/` contains incremental PostgreSQL migrations.
- Deployment and local development scripts should execute migrations from this directory.
- Historical database directories are kept temporarily for compatibility during the migration:
  - `docs/database/`
  - `kiki_server/migrations/`
  - `scripts/deploy-release/db/`

Do not add new executable SQL to the legacy directories.

## Migration Naming

Use:

```text
NNN_short_description.sql
```

Rules:

- Version numbers must be unique.
- Do not edit migrations that may already have been applied.
- Add a new higher-numbered migration for changes.
- SQL must be PostgreSQL-compatible.
- Prefer idempotent DDL such as `IF NOT EXISTS`.

## Current Migration Map

The new facts source starts from the current production deploy migration set and then adds missing backend migrations with non-conflicting production version numbers.

| New file | Source |
|---|---|
| `001_add_role_support.sql` | `scripts/deploy-release/db/migrations/001_add_role_support.sql` |
| `002_scene_tables.sql` | `scripts/deploy-release/db/migrations/002_scene_tables.sql` |
| `003_scenes_add_columns.sql` | `scripts/deploy-release/db/migrations/003_scenes_add_columns.sql` |
| `004_feedback_tables.sql` | `scripts/deploy-release/db/migrations/004_feedback_tables.sql` |
| `005_create_learning_tables.sql` | `scripts/deploy-release/db/migrations/005_create_learning_tables.sql` |
| `006_fix_user_roles.sql` | `kiki_server/migrations/005_fix_user_roles.sql` |
| `007_subscription_commercialization.sql` | `kiki_server/migrations/006_subscription_commercialization.sql` |

The old `005_fix_user_roles.sql` was not copied as version `005` because `005_create_learning_tables.sql` is already the production deploy version for `005`. The release script records only the numeric prefix in `schema_migrations`, so duplicate version numbers would be skipped.

## PostgreSQL Compatibility

Do not use MySQL dialects:

- `AUTO_INCREMENT`
- `TINYINT(1)`
- `DATETIME`
- `ON DUPLICATE KEY UPDATE`
- `ENGINE=InnoDB`
- table-level `CHARSET` or `COLLATE`

Use PostgreSQL equivalents:

- `BIGSERIAL` or `SERIAL`
- `BOOLEAN`
- `TIMESTAMP` or `TIMESTAMPTZ`
- `INSERT ... ON CONFLICT (...) DO UPDATE`

## Snapshots

`snapshots/` stores exported schema snapshots for inspection and documentation. Snapshots are not executed by deployment scripts.
