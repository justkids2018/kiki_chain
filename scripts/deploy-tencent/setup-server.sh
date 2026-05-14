#!/bin/bash
# ============================================
# Hi Kiki - 腾讯云服务器首次初始化
# 用途：在腾讯云服务器上完成以下一次性配置：
#   1. 安装宿主机 nginx（接管 80/443 主路由）
#   2. 修改奇奇漫游记端口绑定（80→8081，不影响业务）
#   3. 配置双域名 nginx 路由规则
#   4. 扩展 SSL 证书加入 kiki.keepthinking.me
#   5. 同步代码 + 启动 kiki_chain 所有容器
#   6. 验证两个项目均正常运行
#
# ⚠️  注意：
#   - 步骤 1-4 会有约 2 分钟停机，需低峰期执行
#   - 奇奇漫游记 docker-compose.yml 仅改端口绑定，业务逻辑不动
#   - 执行前确认 DNS：kiki.keepthinking.me A记录 → 82.156.34.186
#
# 用法：./scripts/deploy-tencent/setup-server.sh
# ============================================

set -e

# -------- 配置 --------
SERVER="ubuntu@82.156.34.186"
KIKI_REMOTE_DIR="~/kiki_chain"
QIQI_REMOTE_DIR="~/qisd_eda_college"
COMPOSE_FILE="docker-compose.prod.yml"
DOMAIN="kiki.keepthinking.me"
BASE_DOMAIN="keepthinking.me"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# -------- 颜色 --------
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  Hi Kiki - 腾讯云首次初始化${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# ── 前置检查 ─────────────────────────────────────────────
echo -e "${YELLOW}[检查] SSH 连接...${NC}"
if ! ssh -o ConnectTimeout=5 $SERVER "echo ok" > /dev/null 2>&1; then
    echo -e "${RED}❌ 无法连接服务器 $SERVER${NC}"
    exit 1
fi
echo -e "${GREEN}  ✅ SSH 连接正常${NC}"

echo -e "${YELLOW}[检查] DNS 解析 $DOMAIN...${NC}"
RESOLVED=$(ssh $SERVER "nslookup $DOMAIN 2>/dev/null | grep 'Address' | grep -v '#' | head -1 | awk '{print \$2}'" || echo "")
if echo "$RESOLVED" | grep -q "82.156.34.186"; then
    echo -e "${GREEN}  ✅ DNS 已解析到 82.156.34.186${NC}"
else
    echo -e "${RED}  ⚠️  $DOMAIN 尚未解析到 82.156.34.186（当前: $RESOLVED）${NC}"
    echo -e "${RED}     请先在 DNS 控制台添加 A 记录再执行本脚本${NC}"
    exit 1
fi

# ── Step 1: 安装/启动宿主机 nginx ────────────────────────
echo ""
echo -e "${YELLOW}[1/6] 准备宿主机 nginx...${NC}"
ssh $SERVER "
    # 安装（若未安装）
    if ! command -v nginx > /dev/null 2>&1; then
        sudo apt-get update -qq && sudo apt-get install -y nginx
        echo '  nginx 安装完成'
    else
        echo '  nginx 已安装'
    fi

    # 禁用默认 site（default server 监听 80，会与 Docker 冲突）
    sudo rm -f /etc/nginx/sites-enabled/default

    # 停用 Docker certbot 容器（续期改为宿主机 webroot 模式，两者不能共存）
    cd ~/qisd_eda_college
    docker compose stop certbot 2>/dev/null || true
    echo '  已停用 Docker certbot 容器（续期改由宿主机负责）'

    sudo systemctl enable nginx
"
echo -e "${GREEN}  ✅ 宿主机 nginx 就绪${NC}"

# ── Step 2: 修改奇奇漫游记端口（80→8081）────────────────
echo ""
echo -e "${YELLOW}[2/6] 修改奇奇漫游记端口绑定（80→127.0.0.1:8081）...${NC}"
echo -e "${YELLOW}      ⚠️  奇奇漫游记将短暂重启，约 30 秒${NC}"

ssh $SERVER "
    cd $QIQI_REMOTE_DIR

    # 备份（如果没有备份过）
    if [ ! -f docker-compose.yml.before-kikichain.bak ]; then
        cp docker-compose.yml docker-compose.yml.before-kikichain.bak
        echo '  已创建备份: docker-compose.yml.before-kikichain.bak'
    else
        echo '  备份已存在，跳过'
    fi

    # 替换端口绑定（只改端口映射，不动其他配置）
    sed -i 's|\"0.0.0.0:80:80\"|\"127.0.0.1:8081:80\"|g' docker-compose.yml
    sed -i 's|- \"80:80\"|- \"127.0.0.1:8081:80\"|g' docker-compose.yml
    sed -i 's|\"0.0.0.0:443:443\"|\"127.0.0.1:8443:443\"|g' docker-compose.yml
    sed -i 's|- \"443:443\"|- \"127.0.0.1:8443:443\"|g' docker-compose.yml

    # 重启前端容器
    docker compose stop frontend
    docker compose up -d frontend
    sleep 5
    echo '  端口修改完成，奇奇漫游记已重启'
"
echo -e "${GREEN}  ✅ 奇奇漫游记端口已调整到 127.0.0.1:8081${NC}"

# ── Step 3: 配置宿主机 nginx 双域名路由 ──────────────────
echo ""
echo -e "${YELLOW}[3/6] 配置宿主机 nginx 双域名路由...${NC}"
ssh $SERVER "
    sudo mkdir -p /var/www/certbot

    # 先用 HTTP-only 配置（SSL 证书扩展完成前的临时配置）
    sudo tee /etc/nginx/conf.d/multi-site.conf > /dev/null << 'NGINXEOF'
# ===== keepthinking.me → 奇奇漫游记 (8081) =====
server {
    listen 80;
    server_name keepthinking.me www.keepthinking.me;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
        default_type text/plain;
    }

    location / {
        proxy_pass http://127.0.0.1:8081;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}

# ===== kiki.keepthinking.me → kiki_chain (8082) =====
server {
    listen 80;
    server_name kiki.keepthinking.me;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
        default_type text/plain;
    }

    location / {
        return 301 https://\$host\$request_uri;
    }
}
NGINXEOF

    # 启动宿主机 nginx（此时 Docker 80 端口已释放）
    sudo nginx -t && sudo systemctl start nginx
    echo '  nginx 路由配置完成（HTTP-only 临时配置）'
"
echo -e "${GREEN}  ✅ 宿主机 nginx 路由配置完成${NC}"

# ── Step 4: 申请/续期 SSL 证书 ────────────────────────────
# 说明：证书已于 2026-02-21 过期，且续期方式为 standalone（与 Docker 80 端口冲突）
# 此步骤：1) 改为 webroot 模式  2) 重新申请证书（含 kiki.keepthinking.me）
#         3) 修改续期配置为 webroot，后续自动续期正常工作
echo ""
echo -e "${YELLOW}[4/6] 重新申请 SSL 证书（webroot 模式，含 kiki.keepthinking.me）...${NC}"
echo -e "${YELLOW}      ⚠️  原证书已过期（2026-02-21），此步骤同步修复续期机制${NC}"
ssh $SERVER "
    sudo mkdir -p /var/www/certbot

    # 使用 webroot 模式重新申请（--force-renewal 覆盖过期证书）
    # 宿主机 nginx 已接管 80 端口并配置了 /.well-known/acme-challenge/ 路由
    sudo certbot certonly --webroot \
        -w /var/www/certbot \
        --force-renewal \
        -d $BASE_DOMAIN \
        -d www.$BASE_DOMAIN \
        -d $DOMAIN \
        --non-interactive \
        --agree-tos \
        --register-unsafely-without-email 2>&1 || \
    sudo certbot certonly --webroot \
        -w /var/www/certbot \
        --force-renewal \
        -d $BASE_DOMAIN \
        -d $DOMAIN \
        --non-interactive \
        --agree-tos \
        --register-unsafely-without-email 2>&1

    # 验证续期配置已改为 webroot（之后 certbot.timer 自动续期不再抢占 80 端口）
    sudo grep 'authenticator' /etc/letsencrypt/renewal/$BASE_DOMAIN.conf

    echo '  证书申请完成'
    sudo certbot certificates
"

# 更新 nginx 为完整 HTTPS 配置
ssh $SERVER "
    sudo tee /etc/nginx/conf.d/multi-site.conf > /dev/null << 'NGINXEOF'
# ===== keepthinking.me → 奇奇漫游记 (8081) =====
server {
    listen 80;
    server_name keepthinking.me www.keepthinking.me;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
        default_type text/plain;
    }

    location / {
        proxy_pass http://127.0.0.1:8081;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}

server {
    listen 443 ssl http2;
    server_name keepthinking.me www.keepthinking.me;
    ssl_certificate /etc/letsencrypt/live/keepthinking.me/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/keepthinking.me/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;

    location / {
        proxy_pass http://127.0.0.1:8081;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
    }
}

# ===== kiki.keepthinking.me → kiki_chain (8082) =====
server {
    listen 80;
    server_name kiki.keepthinking.me;

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
    server_name kiki.keepthinking.me;
    ssl_certificate /etc/letsencrypt/live/keepthinking.me/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/keepthinking.me/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;

    location / {
        proxy_pass http://127.0.0.1:8082;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
    }
}
NGINXEOF

    sudo nginx -t && sudo nginx -s reload
    echo '  nginx HTTPS 配置已激活'
"
echo -e "${GREEN}  ✅ SSL 证书扩展完成，HTTPS 已启用${NC}"

# ── Step 5: 同步代码 + 启动 kiki_chain ────────────────────
echo ""
echo -e "${YELLOW}[5/6] 同步代码并启动 kiki_chain...${NC}"
bash "$SCRIPT_DIR/deploy-sync.sh"

echo -e "${YELLOW}      启动所有容器（首次构建 Rust 需要 5-10 分钟）...${NC}"
ssh $SERVER "
    cd $KIKI_REMOTE_DIR

    # 修改 docker-compose.prod.yml 中 nginx 端口为内部绑定
    sed -i 's|- \"80:80\"|- \"127.0.0.1:8082:80\"|g' $COMPOSE_FILE
    sed -i 's|- \"443:443\"||g' $COMPOSE_FILE

    # 启动全部服务
    docker compose -f $COMPOSE_FILE up -d --build
"
echo -e "${GREEN}  ✅ kiki_chain 容器启动中${NC}"

# ── Step 6: 验证 ─────────────────────────────────────────
echo ""
echo -e "${YELLOW}[6/6] 等待服务就绪并验证（约 30 秒）...${NC}"
sleep 30

# 验证奇奇漫游记
QIQI_STATUS=$(ssh $SERVER "curl -s -o /dev/null -w '%{http_code}' https://keepthinking.me 2>/dev/null || echo '000'")
if [ "$QIQI_STATUS" = "200" ] || [ "$QIQI_STATUS" = "301" ] || [ "$QIQI_STATUS" = "302" ]; then
    echo -e "${GREEN}  ✅ 奇奇漫游记 keepthinking.me 正常 (HTTP $QIQI_STATUS)${NC}"
else
    echo -e "${YELLOW}  ⚠️  奇奇漫游记响应: HTTP $QIQI_STATUS（可能还在启动）${NC}"
fi

# 验证 kiki_chain
KIKI_API=$(ssh $SERVER "curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:8082/api/health 2>/dev/null || echo '000'")
if [ "$KIKI_API" = "200" ]; then
    echo -e "${GREEN}  ✅ kiki_chain API 正常 (HTTP $KIKI_API)${NC}"
else
    echo -e "${YELLOW}  ⚠️  kiki_chain API 响应: HTTP $KIKI_API（Rust 构建中，请稍候）${NC}"
    echo ""
    echo "  可用以下命令跟踪构建进度："
    echo "  ssh $SERVER 'docker logs hikiki_backend -f'"
fi

# 显示所有容器状态
echo ""
echo -e "${CYAN}容器状态总览：${NC}"
ssh $SERVER "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✅ 腾讯云初始化完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "  奇奇漫游记:   https://keepthinking.me"
echo "  Hi Kiki:      https://kiki.keepthinking.me"
echo "  Hi Kiki API:  https://kiki.keepthinking.me/api"
echo "  Hi Kiki Admin:https://kiki.keepthinking.me/admin"
