#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/deploy-release/bin/common.sh
source "$SCRIPT_DIR/bin/common.sh"

PROFILE_NAME="${1:-}"
load_profile "$PROFILE_NAME"
TLS_CERT_DOMAIN="${DEPLOY_TLS_CERT_DOMAIN:-keepthinking.me}"

if [[ "${DEPLOY_MOBILE_DOMAIN}" == "${DEPLOY_PRIMARY_DOMAIN}" ]]; then
  MOBILE_SERVER_NAMES="${DEPLOY_MOBILE_DOMAIN}"
else
  MOBILE_SERVER_NAMES="${DEPLOY_MOBILE_DOMAIN} ${DEPLOY_PRIMARY_DOMAIN}"
fi

print_header "安装宿主机 Nginx 域名入口 (${DEPLOY_PROVIDER})"

if [[ ! -f "$LOCAL_LATEST_DIR/deploy.env" ]]; then
  echo -e "${RED}❌ 未找到部署产物 deploy.env，请先执行 step1-prepare.sh${NC}"
  exit 1
fi

ensure_ssh

cat >"$LOCAL_LATEST_DIR/host-nginx.conf" <<EOF
# Managed by scripts/deploy-release/install-host-nginx.sh
# Purpose: route public domains to unified stack localhost ports.

server {
  listen 80;
  server_name ${MOBILE_SERVER_NAMES};

  location /.well-known/acme-challenge/ {
    root /var/www/certbot;
    default_type text/plain;
  }

  location / {
    return 301 https://\$host\$request_uri;
  }
}

server {
  listen 443 ssl http2;
  server_name ${MOBILE_SERVER_NAMES};

  ssl_certificate /etc/letsencrypt/live/${TLS_CERT_DOMAIN}/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/${TLS_CERT_DOMAIN}/privkey.pem;
  ssl_protocols TLSv1.2 TLSv1.3;
  ssl_prefer_server_ciphers on;
  ssl_session_cache shared:SSL:10m;

  location /api/ {
    proxy_pass http://127.0.0.1:${DEPLOY_BACKEND_HOST_PORT};
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto https;
  }

  location /cdn/ {
    proxy_pass https://img.keepthinking.me/;
    proxy_set_header Host img.keepthinking.me;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto https;
  }

  location / {
    proxy_pass http://127.0.0.1:${DEPLOY_ADMIN_HOST_PORT};
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto https;
  }
}

server {
  listen 80;
  server_name ${DEPLOY_ADMIN_DOMAIN};

  location /.well-known/acme-challenge/ {
    root /var/www/certbot;
    default_type text/plain;
  }

  location / {
    return 301 https://\$host\$request_uri;
  }
}

server {
  listen 443 ssl http2;
  server_name ${DEPLOY_ADMIN_DOMAIN};

  ssl_certificate /etc/letsencrypt/live/${TLS_CERT_DOMAIN}/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/${TLS_CERT_DOMAIN}/privkey.pem;
  ssl_protocols TLSv1.2 TLSv1.3;
  ssl_prefer_server_ciphers on;
  ssl_session_cache shared:SSL:10m;

  location /cdn/ {
    proxy_pass https://img.keepthinking.me/;
    proxy_set_header Host img.keepthinking.me;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto https;
  }

  location / {
    proxy_pass http://127.0.0.1:${DEPLOY_ADMIN_HOST_PORT};
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto https;
  }
}
EOF

scp "$LOCAL_LATEST_DIR/host-nginx.conf" "$SERVER:/tmp/kiki-unified.conf" >/dev/null

ssh "$SERVER" "sudo mkdir -p /etc/nginx/conf.d && sudo mv /tmp/kiki-unified.conf /etc/nginx/conf.d/kiki-unified.conf && sudo nginx -t && sudo systemctl reload nginx"

echo -e "${GREEN}✅ 宿主机 Nginx 已加载: /etc/nginx/conf.d/kiki-unified.conf${NC}"
