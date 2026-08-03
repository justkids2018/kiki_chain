# 服务器 Nginx 证书

## 当前架构

- `scripts/deploy-release/profiles/tencent.env` 配置 `DEPLOY_TLS_CERT_DOMAIN=keepthinking.me`。
- 宿主机 Nginx 读取：
  - `/etc/letsencrypt/live/<TLS_CERT_DOMAIN>/fullchain.pem`
  - `/etc/letsencrypt/live/<TLS_CERT_DOMAIN>/privkey.pem`
- Nginx 配置已提供 `/.well-known/acme-challenge/` Webroot 路径。
- 服务器证书不负责 `img.keepthinking.me`；七牛 CDN 证书也不能替换服务器证书。

2026-08-01 线上检查结果：

| 证书 | SAN | 截止时间（北京时间） |
|---|---|---|
| `keepthinking.me` | `admin.keepthinking.me`、`keepthinking.me`、`kiki.keepthinking.me`、`www.keepthinking.me` | 2026-08-17 17:04:45 |
| `all.keepthinking.me` | `all.keepthinking.me`、`down.kiki.keepthinking.me` | 2026-09-07 22:26:27 |

> 本轮不修改服务器证书，但 `keepthinking.me` 证书更早到期，需要单独检查自动续期。

## 生成规则

服务器首次签发或扩展 SAN 前，必须先确认：

1. 所有域名解析到目标服务器。
2. 80 端口和 `/.well-known/acme-challenge/` 可从公网访问。
3. 当前 Nginx `server_name`、证书 SAN 与计划域名清单一致。
4. 已记录原证书路径、线上指纹和 Nginx 配置回滚点。

Webroot 签发示例：

```bash
sudo certbot certonly --webroot \
  -w /var/www/certbot \
  -d keepthinking.me \
  -d www.keepthinking.me \
  -d kiki.keepthinking.me \
  -d admin.keepthinking.me
```

产品静态站应使用独立证书名称和准确 SAN：

```bash
sudo certbot certonly --webroot \
  -w /var/www/certbot \
  -d all.keepthinking.me \
  -d down.kiki.keepthinking.me
```

不要照抄命令覆盖线上证书；执行前应以服务器 `sudo certbot certificates` 的实际证书名称为准。

## 自动续期规则

```bash
# 只演练，不替换线上证书
sudo certbot renew --dry-run

# 查看证书与定时器
sudo certbot certificates
systemctl list-timers | grep -i certbot
```

续期成功后必须重载实际承载 TLS 的宿主机 Nginx：

```bash
sudo certbot renew --deploy-hook "systemctl reload nginx"
```

如果实际 Nginx 在容器内，deploy hook 必须替换为对应的容器重载命令。

## 验证

```bash
sudo nginx -t

for domain in kiki.keepthinking.me admin.keepthinking.me all.keepthinking.me down.kiki.keepthinking.me; do
  echo "== $domain =="
  echo | openssl s_client -servername "$domain" -connect "$domain":443 2>/dev/null \
    | openssl x509 -noout -subject -issuer -dates
done
```

验证证书后，还要检查管理后台、API 健康检查与产品静态站。
