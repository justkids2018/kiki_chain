# 七牛 CDN 证书：`img.keepthinking.me`

## 当前架构

- `img.keepthinking.me` 的 CNAME 指向七牛 CDN。
- 图片、音频和 APK 通过该域名访问。
- TLS 在七牛边缘节点终止；服务器 Nginx 的 `/cdn/` 仅反向代理该地址，不负责为它换证。
- 当前线上证书由 Let's Encrypt 签发，有效期为北京时间 2026-05-31 22:11:37 至 2026-08-29 22:11:36。
- 当前仓库没有“申请证书并自动更新七牛 CDN 绑定”的自动化脚本。

## 推荐生成方式

本项目采用 `acme.sh + Let's Encrypt + DNS-01` 生成一张新的 RSA 2048 单域名证书。DNS 托管在 DNSPod；没有配置 DNSPod API 凭据时，使用手动 DNS 验证。

### 第一步：创建订单并获取 TXT 验证记录

```bash
acme.sh --issue \
  --server letsencrypt \
  --dns \
  -d img.keepthinking.me \
  --keylength 2048 \
  --yes-I-know-dns-manual-mode-enough-go-ahead-please
```

命令会输出 `_acme-challenge.img.keepthinking.me` 所需的 TXT 值。到 DNSPod 添加该记录，等待公网解析生效。

### 第二步：完成验证与签发

```bash
acme.sh --renew \
  --server letsencrypt \
  -d img.keepthinking.me \
  --yes-I-know-dns-manual-mode-enough-go-ahead-please
```

### 第三步：导出七牛可上传文件

```bash
mkdir -p local-secrets/certificates/img.keepthinking.me

acme.sh --install-cert -d img.keepthinking.me \
  --key-file local-secrets/certificates/img.keepthinking.me/privkey.pem \
  --fullchain-file local-secrets/certificates/img.keepthinking.me/fullchain.pem

chmod 600 local-secrets/certificates/img.keepthinking.me/privkey.pem
```

最终交付文件：

- `local-secrets/certificates/img.keepthinking.me/fullchain.pem`
- `local-secrets/certificates/img.keepthinking.me/privkey.pem`

## 上传并绑定到七牛

1. 登录[七牛证书管理平台](https://portal.qiniu.com/certificate/ssl)。
2. 选择「上传自有证书」。
3. 证书内容使用 `fullchain.pem`，证书私钥使用 `privkey.pem`。
4. 进入「CDN → 域名管理 → `img.keepthinking.me` → HTTPS 配置」。
5. 选择刚上传的新证书并提交。
6. 确认强制 HTTPS、HTTP/2 等原有设置没有意外变化。

七牛官方参考：

- [自有证书上传 FAQ](https://developer.qiniu.com/fusion/kb/3905/ssl-certificate-faq)
- [CDN HTTPS 配置与更换证书](https://developer.qiniu.com/fusion/4952/https-configuration)

## 上传前检查

```bash
openssl x509 \
  -in local-secrets/certificates/img.keepthinking.me/fullchain.pem \
  -noout -subject -issuer -dates -fingerprint -sha256

openssl x509 \
  -in local-secrets/certificates/img.keepthinking.me/fullchain.pem \
  -noout -text | sed -n '/Subject Alternative Name/,+1p'
```

必须满足：

- SAN 包含且只需要覆盖 `img.keepthinking.me`。
- 截止时间是新证书的时间，不是 2026-08-29。
- 证书与私钥匹配。
- 私钥权限为 `600`，文件没有被 Git 跟踪。

## 上传后验证

```bash
dig +short CNAME img.keepthinking.me

echo | openssl s_client \
  -servername img.keepthinking.me \
  -connect img.keepthinking.me:443 2>/dev/null \
  | openssl x509 -noout -subject -issuer -dates -fingerprint -sha256

curl -I https://img.keepthinking.me/download/hikiki/hikiki_app.apk
```

还要验证一张实际图片、一个音频文件，以及 `https://kiki.keepthinking.me/cdn/...` 代理路径。

## 回滚

新证书绑定失败时，在七牛 CDN HTTPS 配置中重新选择旧证书。旧证书在 2026-08-29 22:11:36 前仍可作为短期回滚点；不得因此推迟修复新证书。
