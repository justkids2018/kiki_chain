# Hi Kiki Product Page

本目录用于 Hi Kiki 对外展示与下载页面。

## 入口

- `index.html`：下载页（含“故事视频”入口）
- `video/index.html`：故事视频播放页（可直接录屏导出）
- `video/README.md`：Video Kit 使用说明

## 建议工作流

1. 在 `video/index.html` 更新 `VIDEO_CONFIG`（镜头、文案、时长）
2. 本地浏览器预览并调整节奏
3. 录屏导出后在剪映/CapCut 补字幕与BGM
4. 发布短视频并回收数据迭代脚本

## 官网部署

线上入口：

- `https://down.kiki.keepthinking.me/index.html`

部署 workflow：

- 推荐一起发布全部产品静态站：`.github/workflows/product-static-sites-release.yml`
- `.github/workflows/hikiki-static-release.yml`

发布策略：

1. 只发布 `kiki_product_html/hikiki/` 静态文件，不进入后端/admin Docker 发布链路。
2. workflow 会打包当前目录，上传到服务器 `releases/<release_id>`，再原子切换 `current`。
3. 默认保留最近 5 个 release 目录，旧版本可在服务器上把 `current` symlink 切回。
4. 首次接入域名时，优先手动运行 `Product Static Sites Release` 并勾选 `install_nginx`，一次生成 `all.keepthinking.me` 与 `down.kiki.keepthinking.me` 的 nginx 配置。
5. 后续改页面只需要 push 到 `main`，推荐由 `Product Static Sites Release` 一起发布两个静态站并校验访问地址。

需要配置的 GitHub Secrets：

1. `TENCENT_SSH_PRIVATE_KEY`：服务器 SSH 私钥。
2. `DEPLOY_SERVER_IP`：服务器 IP。
3. `DEPLOY_SSH_USER`：服务器用户。
4. `HIKIKI_REMOTE_DIR`：可选，默认 `~/hikiki_static`。
5. `HIKIKI_TLS_CERT_DOMAIN`：可选，默认 `keepthinking.me`，要求服务器已有 `/etc/letsencrypt/live/<domain>/fullchain.pem`。

首次部署前置条件：

1. `down.kiki.keepthinking.me` DNS 已解析到目标服务器。
2. 服务器 nginx 已安装。
3. 服务器证书必须覆盖 `down.kiki.keepthinking.me`；如果当前 `keepthinking.me` 证书不是泛域名证书，需要先申请包含该子域名的证书。
