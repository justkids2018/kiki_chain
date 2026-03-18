# 七牛云上传测试指南

## ✅ 已完成配置

### 1. 后端配置
- ✅ 七牛云配置已启用（`.env` 文件）
- ✅ 图片统一上传到 `kiki/` 目录
- ✅ 文件结构：`kiki/{folder}/{uuid}.{ext}`

### 2. 管理后台
- ✅ 分类管理：封面图支持上传
- ✅ 场景管理：封面图 + 互动大图支持上传

### 3. 图片存储路径

所有图片都会上传到七牛云的以下路径：

```
kiki/
├── categories/     # 分类封面
│   └── {uuid}.jpg
├── scenes/         # 场景封面和互动图
│   ├── {uuid}.jpg
│   └── {uuid}.png
└── avatars/        # 用户头像（未来）
    └── {uuid}.jpg
```

访问 URL 示例：
```
https://img.mtrain.xyz/kiki/categories/abc-123-def.jpg
https://img.mtrain.xyz/kiki/scenes/xyz-456-uvw.png
```

## 🚀 测试步骤

### 1. 启动后端服务

```bash
cd kiki_server
cargo run
```

看到以下日志表示七牛云配置成功：
```
✅ 七牛云服务初始化成功
```

### 2. 启动管理后台

```bash
cd kiki_admin
npm run dev
```

### 3. 测试分类封面上传

1. 访问 http://localhost:5173
2. 登录管理后台
3. 进入「场景分类」页面
4. 点击「新建分类」或「编辑」
5. 在「封面图」区域点击上传
6. 选择图片（JPG/PNG，最大 5MB）
7. 上传成功后会自动显示预览
8. 保存分类

### 4. 测试场景图片上传

1. 进入「场景管理」页面
2. 点击「新建场景」或「编辑」
3. 上传「封面图」和「互动大图」
4. 保存场景

### 5. 验证图片 URL

上传成功后，图片 URL 应该是：
```
https://img.mtrain.xyz/kiki/categories/{uuid}.jpg
https://img.mtrain.xyz/kiki/scenes/{uuid}.jpg
```

在浏览器中访问这个 URL，应该能看到图片。

## 🔍 故障排查

### 问题 1: 上传失败，提示"七牛云服务未配置"

**原因**: 环境变量未加载

**解决**:
```bash
# 检查 .env 文件
cat kiki_server/.env | grep QINIU

# 确保没有 # 注释符号
# 重启后端服务
```

### 问题 2: 上传失败，提示"Upload failed"

**原因**: 七牛云密钥或 Bucket 配置错误

**解决**:
1. 登录七牛云控制台
2. 检查 Bucket 名称是否为 `19kiki`
3. 检查 AccessKey 和 SecretKey 是否正确
4. 确保 Bucket 访问控制设置为「公开」

### 问题 3: 图片上传成功但无法访问

**原因**: 域名配置问题

**解决**:
1. 检查 `QINIU_DOMAIN` 是否正确（`img.mtrain.xyz`）
2. 确保域名已绑定到七牛云 Bucket
3. 检查域名 CNAME 解析是否生效：
```bash
nslookup img.mtrain.xyz
```

### 问题 4: 管理后台上传按钮无响应

**原因**: 前端组件未正确导入

**解决**:
```bash
# 检查 ImageUpload 组件是否存在
ls kiki_admin/src/components/ImageUpload.vue

# 重启前端服务
cd kiki_admin
npm run dev
```

## 📊 上传限制

- 文件大小：最大 5MB
- 支持格式：JPG, PNG, GIF, WebP
- 文件命名：自动生成 UUID，避免重名
- 存储位置：统一在 `kiki/` 目录下

## 🎯 下一步

- [ ] 测试分类封面上传
- [ ] 测试场景图片上传
- [ ] 验证移动端图片显示
- [ ] 检查图片 CDN 访问速度

---

**配置完成时间**: 2026-03-17
**七牛云 Bucket**: 19kiki
**CDN 域名**: img.mtrain.xyz
