# Product All Page

本目录用于所有产品的统一介绍页。

## 入口

- 线上地址：`https://all.keepthinking.me/`
- 本地入口：`index.html`

## 产品跳转

- Hi Kiki 下载页：`https://down.kiki.keepthinking.me/index.html`

## 部署

部署 workflow：

- 推荐一起发布全部产品静态站：`.github/workflows/product-static-sites-release.yml`
- `.github/workflows/product-all-static-release.yml`

发布策略：

1. 只发布 `kiki_product_html/all/` 静态文件。
2. workflow 会上传到服务器 `releases/<release_id>`，再原子切换 `current`。
3. 首次接入域名时，优先手动运行 `Product Static Sites Release` 并勾选 `install_nginx`，一次生成 `all.keepthinking.me` 与 `down.kiki.keepthinking.me` 的 nginx 配置。
4. 后续改页面并 push 到 `main`，推荐由 `Product Static Sites Release` 一起发布两个静态站。

需要配置的 GitHub Secrets：

1. `TENCENT_SSH_PRIVATE_KEY`
2. `DEPLOY_SERVER_IP`
3. `DEPLOY_SSH_USER`
4. `PRODUCT_ALL_REMOTE_DIR`：可选，默认 `~/product_all_static`
5. `PRODUCT_ALL_TLS_CERT_DOMAIN`：可选，默认 `keepthinking.me`

首次部署前置条件：

1. `all.keepthinking.me` DNS 已解析到目标服务器。
2. 服务器 nginx 已安装。
3. 服务器证书必须覆盖 `all.keepthinking.me`；如果当前证书不是泛域名证书，需要先申请包含该子域名的证书。
