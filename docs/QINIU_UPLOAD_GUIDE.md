# 七牛云图片上传功能使用指南

## 📦 功能概述

已成功集成七牛云图片上传功能到 Hi Kiki 项目，支持管理后台上传场景分类封面、场景封面等图片。

## 🔧 配置步骤

### 1. 注册七牛云账号

1. 访问 [七牛云官网](https://www.qiniu.com/)
2. 注册账号并完成实名认证
3. 免费额度：10GB 存储 + 10GB 流量/月

### 2. 创建存储空间

1. 登录七牛云控制台
2. 进入「对象存储」→「空间管理」
3. 点击「新建空间」
   - 空间名称：如 `hikiki-images`
   - 存储区域：选择离用户最近的区域
   - 访问控制：选择「公开」
4. 创建成功���，记录以下信息：
   - Bucket 名称
   - CDN 域名（如 `xxx.bkt.clouddn.com`）

### 3. 获取密钥

1. 进入「个人中心」→「密钥管理」
2. 记录以下信息：
   - AccessKey
   - SecretKey

### 4. 配置后端环境变量

编辑 `kiki_server/.env` 文件，添加七牛云配置：

```bash
# 七牛云配置
QINIU_ACCESS_KEY=your_access_key_here
QINIU_SECRET_KEY=your_secret_key_here
QINIU_BUCKET=hikiki-images
QINIU_DOMAIN=xxx.bkt.clouddn.com
```

⚠️ **注意**：
- 不要提交 `.env` 文件到 Git
- 生产环境使用独立的密钥

## 🚀 使用方法

### 管理后台上传图片

1. 启动后端服务：
```bash
cd kiki_server
cargo run
```

2. 启动管理后台：
```bash
cd kiki_admin
npm run dev
```

3. 在分类管理页面：
   - 点击「新建分类」或「编辑」
   - 在「封面图」字段，点击上传区域
   - 选择图片文件（支持 JPG、PNG，最大 5MB）
   - 上传成功后自动显示预览
   - 保存分类

### API 接口

**上传图片**

```http
POST /api/v1/admin/upload/image
Content-Type: multipart/form-data
Authorization: Bearer <token>

file: <图片文件>
folder: categories  # 可选，默认 "images"
```

**响应**

```json
{
  "success": true,
  "data": {
    "url": "https://xxx.bkt.clouddn.com/categories/uuid.jpg",
    "folder": "categories",
    "filename": "image.jpg"
  },
  "message": "上传成功"
}
```

## 📁 文件组织

上传的图片按文件夹分类存储：

- `categories/` - 场景分类封面
- `scenes/` - 场景封面
- `avatars/` - 用户头像
- `images/` - 其他图片

## 🔍 技术实现

### 后端

- **文件**: `kiki_server/src/adapters/storage/qiniu_service.rs`
- **接口**: `kiki_server/src/framework/bootstrap/routes/admin.rs`
- **依赖**: reqwest, hmac, sha1

### 前端

- **API**: `kiki_admin/src/api/upload.ts`
- **组件**: `kiki_admin/src/components/ImageUpload.vue`
- **使用**: `kiki_admin/src/views/Categories.vue`

## ⚠️ 注意事项

1. **图片大小限制**: 最大 5MB
2. **支持格式**: JPG, PNG, GIF, WebP
3. **文件命名**: 自动生成 UUID，避免重名
4. **CDN 加速**: 使用七牛云 CDN，全国访问速度快
5. **安全性**: 上传接口需要管理员权限

## 🐛 故障排查

### 上传失败

1. 检查七牛云配置是否正确
2. 检查 Bucket 是否设置为公开
3. 检查密钥是否有效
4. 查看后端日志：`cargo run`

### 图片无法访问

1. 检查 CDN 域名是否正确
2. 检查 Bucket 访问控制设置
3. 检查图片 URL 是否完整

### 编译错误

```bash
cd kiki_server
cargo clean
cargo build
```

## 📊 成本估算

**免费额度**（每月）：
- 存储：10GB
- 流量：10GB
- 请求：100万次

**超出后费用**：
- 存储：¥0.12/GB/月
- 流量：¥0.5/GB（使用 CDN）
- 小项目每月几块钱

## 🎯 后续优化

- [ ] 添加图片压缩功能
- [ ] 支持批量上传
- [ ] 添加图片裁剪功能
- [ ] 实现图片水印
- [ ] 添加上传进度显示

---

**版本**: v1.0
**更新时间**: 2026-03-17
**维护者**: Development Team
