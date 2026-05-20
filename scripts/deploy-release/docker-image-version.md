# Docker Image Version

- Updated At: 2026-05-19 21:35:39
- Commit: 4098213d
- Image Tag: sha-4098213d

## Images

- ghcr.io/justkids2018/kiki-chain-backend:sha-4098213d
- ghcr.io/justkids2018/kiki-chain-admin:sha-4098213d

## Usage

1. Build and push images via GitHub Actions (kiki branch push).
2. Update this version file:
   - ./scripts/deploy-release/update-image-version.sh sha-4098213d
3. Deploy with current tracked version:
   - ./scripts/deploy-release/step1-prepare.sh tencent
   - ./scripts/deploy-release/step2-deploy.sh tencent

