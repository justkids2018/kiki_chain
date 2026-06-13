## Failure Signature

Docker workflow failed during deployment:

```text
Error response from daemon: Conflict. The container name "/kiki_chain-postgres-1" is already in use
```

## Root Cause

The production PostgreSQL container on the server was manually modified/recreated to expose PostgreSQL for remote pgAdmin access. The container kept the Compose-style name `kiki_chain-postgres-1`, but it no longer has Docker Compose labels, so `docker compose -p kiki_chain up -d postgres` does not recognize it as part of the current stack and tries to create a new container with the same name.

The repository deployment config also did not model the intended remote PostgreSQL bind address, so future releases would keep fighting the manual server change.

## Evidence

- Workflow failure: Docker daemon reports name conflict for `/kiki_chain-postgres-1`.
- Server inspection: `kiki_chain-postgres-1` has `labels={}`.
- Server inspection: `kiki_chain-postgres-1` is bound to `0.0.0.0:15432->5432/tcp`.
- Server inspection: the existing volume is `kiki_chain_kiki_unified_pgdata`, so the data volume can be preserved while replacing the container.
- `scripts/deploy-release/docker-compose.yml` previously hard-coded Postgres bind to `127.0.0.1:${DEPLOY_POSTGRES_HOST_PORT}:5432`.

## Affected Scope

- GitHub Actions Docker deploy workflow
- `scripts/deploy-release/docker-compose.yml`
- `scripts/deploy-release/profiles/tencent.env`
- `scripts/deploy-release/step1-prepare.sh`
- `scripts/deploy-release/bin/common.sh`

## Patch Plan

1. Add `DEPLOY_POSTGRES_HOST_BIND` to the deploy profile and generated runtime `.env`.
2. Use `${DEPLOY_POSTGRES_HOST_BIND:-127.0.0.1}` in the Compose Postgres port mapping.
3. Keep Tencent production profile at `0.0.0.0:15432` to support remote pgAdmin access.
4. Add a preflight check for same-name containers that are not managed by the current Compose project.
5. On the server, replace only the unmanaged Postgres container while preserving the volume, then rerun workflow.

## Regression Risk

Medium. PostgreSQL container replacement causes a short database restart, but data is preserved as long as the Docker volume is not removed.

## Verification Plan

1. Run `./scripts/deploy-release/step1-prepare.sh tencent` and verify generated `.env` contains `DEPLOY_POSTGRES_HOST_BIND=0.0.0.0`.
2. Run `docker compose ... config` against the generated env and verify Postgres maps `0.0.0.0:15432:5432`.
3. On the server, confirm `kiki_chain-postgres-1` has Compose labels after recreation.
4. Rerun Docker workflow and confirm deploy passes.
