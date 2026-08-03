# 证书管理

## 目录职责

本目录是 Kiki Chain HTTPS 证书的运维文档入口。项目有两套相互独立的证书生命周期：

| 类型 | 负责域名 | TLS 终止位置 | 操作文档 |
|---|---|---|---|
| 七牛 CDN 证书 | `img.keepthinking.me` | 七牛 CDN 边缘节点 | [qiniu-cdn-certificate.md](./qiniu-cdn-certificate.md) |
| 服务器证书 | `kiki.keepthinking.me`、`admin.keepthinking.me`、产品静态站等 | 生产服务器宿主机 Nginx | [server-certificate.md](./server-certificate.md) |

两类证书即使都由 Let's Encrypt 签发，也不能互相替代：七牛证书必须上传并绑定到七牛 CDN；服务器证书必须部署到服务器 `/etc/letsencrypt/` 并由 Nginx 引用。

## 证书生成规则

### 共同规则

1. 只使用受信任的公有 CA，例如 Let's Encrypt、TrustAsia、DigiCert。
2. 证书 SAN 必须完整覆盖实际对外域名，不能只看证书文件名。
3. 新证书必须生成新私钥，不复用已经进入 Git 历史或来源不明的私钥。
4. 私钥、DNS API 凭据、七牛密钥不得提交 Git、写入文档或发布产物。
5. 证书生成在本地私密目录或服务器 `/etc/letsencrypt/` 完成；仓库只保存操作规则，不保存生产私钥。
6. 换证前记录旧证书的线上指纹和截止时间；换证后核对新指纹、SAN、有效期和关键业务 URL。
7. 剩余 30 天开始告警，14 天升级告警，7 天作为发布阻断问题处理。

### 生成方式选择

| 场景 | 推荐验证方式 | 原因 |
|---|---|---|
| 七牛 CDN `img.keepthinking.me` | DNS-01 | 域名流量在七牛，项目服务器不一定能响应 HTTP challenge |
| 直接指向服务器的普通域名 | HTTP-01/Webroot | Nginx 已提供 `/.well-known/acme-challenge/` 路径 |
| 泛域名证书 | DNS-01 | ACME 泛域名证书必须使用 DNS 验证 |

### 产物格式

七牛上传和 Nginx 部署统一使用：

- `fullchain.pem`：叶子证书加完整中间证书链。
- `privkey.pem`：对应私钥。

上传前必须确认二者匹配：

```bash
cert_pub=$(openssl x509 -in fullchain.pem -pubkey -noout \
  | openssl pkey -pubin -outform DER 2>/dev/null | shasum -a 256)
key_pub=$(openssl pkey -in privkey.pem -pubout -outform DER 2>/dev/null \
  | shasum -a 256)
test "$cert_pub" = "$key_pub"
```

## 仓库安全边界

- 本地新证书默认输出到被 Git 忽略的 `local-secrets/certificates/`。
- `stl_config_key/img.keepthinking.me/privkey.key` 已进入 Git 历史，应视为已暴露，后续证书不得复用该私钥。
- 生产事实源是七牛证书管理平台或服务器 `/etc/letsencrypt/`，不是仓库内的证书副本。
- 清理旧私钥与重写 Git 历史属于独立高风险任务，不能与普通换证混在同一步执行。
