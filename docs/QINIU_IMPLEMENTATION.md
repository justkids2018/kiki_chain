# 七牛云上传功能 - 完整实现

## ✅ 已完成

### 1. 功能封装

所有七牛云上传功能已封装在 `QiniuService` 中：

**文件位置：** `kiki_server/src/adapters/storage/qiniu_service.rs`

**核心方法：**

```rust
impl QiniuService {
    /// 从环境变量创建实例
    pub fn from_env() -> Result<Self>

    /// 获取上传区域（自动查询 Bucket 所在区域）
    async fn get_upload_region(&self) -> Result<String>

    /// 生成上传凭证（按照七牛云官方规范）
    fn generate_upload_token(&self, key: &str) -> String

    /// 上传图片（完整流程）
    pub async fn upload_image(
        &self,
        file_data: Vec<u8>,
        file_name: &str,
        folder: &str,
    ) -> Result<String>
}
```

### 2. 上传凭证生成（符合七牛云官方规范）

根据七牛云文档实现：

```rust
// 1. 构建上传策略
let policy = json!({
    "scope": "bucket:key",
    "deadline": timestamp + 3600,
});

// 2. 序列化为紧凑 JSON
let policy_json = serde_json::to_string(&policy);

// 3. URL 安全的 Base64 编码（无填充）
let encoded_put_policy = base64_url_safe_no_pad(policy_json);

// 4. HMAC-SHA1 签名
let sign = hmac_sha1(secret_key, encoded_put_policy);

// 5. Base64 编码签名
let encoded_sign = base64_url_safe_no_pad(sign);

// 6. 生成凭证
let token = format!("{}:{}:{}", access_key, encoded_sign, encoded_put_policy);
```

### 3. 自动区域选择

系统会自动查询 Bucket 所在区域并使用正确的上传域名：

```rust
// 查询 Bucket 区域
GET https://uc.qiniuapi.com/v4/query?ak={access_key}&bucket={bucket}

// 返回示例（你的 Bucket 在华南 z2）
{
  "hosts": [{
    "region": "z2",
    "up": {
      "domains": ["upload-z2.qiniup.com", "up-z2.qiniup.com"]
    }
  }]
}

// 自动使用正确的上传域名
upload_url = "https://upload-z2.qiniup.com"
```

### 4. 完整上传流程

```
用户上传图片
    ↓
前端 POST /api/v1/admin/upload/image
    ↓
后端接收文件
    ↓
QiniuService::upload_image()
    ├─ 生成唯一文件名: kiki/{folder}/{uuid}.{ext}
    ├─ 查询上传区域: get_upload_region()
    ├─ 生成上传凭证: generate_upload_token()
    ├─ 构建 multipart 表单
    └─ POST 到七牛云上传域名
    ↓
返回 CDN URL: http://img.mtrain.xyz/kiki/{folder}/{uuid}.{ext}
```

## 📝 配置

### 环境变量（.env）

```bash
QINIU_ACCESS_KEY=your_access_key
QINIU_SECRET_KEY=your_secret_key
QINIU_BUCKET=19kiki
QINIU_DOMAIN=img.mtrain.xyz
```

### 依赖项（Cargo.toml）

```toml
reqwest = { version = "0.12", features = ["json", "multipart"] }
hmac = "0.12"
sha1 = "0.10"
base64 = "0.22"
serde_json = "1.0"
```

## 🚀 使用方法

### 后端调用

```rust
// 在 AppState 中初始化
let qiniu_service = QiniuService::from_env()?;

// 上传图片
let url = qiniu_service.upload_image(
    file_data,      // Vec<u8>
    "image.jpg",    // 原始文件名
    "categories"    // 存储文件夹
).await?;

// 返回: https://img.mtrain.xyz/kiki/categories/{uuid}.jpg
```

### 前端调用

```typescript
// 上传图片
const formData = new FormData()
formData.append('file', file)
formData.append('folder', 'categories')

const response = await request.post('/api/v1/admin/upload/image', formData, {
  headers: {
    'Content-Type': 'multipart/form-data',
    'Authorization': `Bearer ${token}`
  }
})

// 返回
{
  "success": true,
  "data": {
    "url": "https://img.mtrain.xyz/kiki/categories/xxx.jpg",
    "folder": "categories",
    "filename": "image.jpg"
  }
}
```

## 🔍 故障排查

### 问题：bad token

**可能原因：**
1. AccessKey 或 SecretKey 不正确
2. Bucket 名称错误或不存在
3. 账号欠费或密钥被禁用

**解决方法：**
1. 登录七牛云控制台确认配置
2. 检查 Bucket 是否存在
3. 确认账号状态正常

### 问题：上传失败

**检查步骤：**
1. 查看后端日志：`tail -f /tmp/kiki_server.log`
2. 确认七牛云服务已初始化：`✅ 七牛云服务初始化成功`
3. 测试区域查询：
   ```bash
   curl "https://uc.qiniuapi.com/v4/query?ak={access_key}&bucket={bucket}"
   ```

## 📊 文件存储结构

```
七牛云 Bucket: 19kiki
├── kiki/
│   ├── categories/     # 分类封面
│   │   └── {uuid}.jpg
│   ├── scenes/         # 场景图片
│   │   ├── {uuid}.jpg
│   │   └── {uuid}.png
│   └── avatars/        # 用户头像
│       └── {uuid}.jpg
```

## 🎯 技术特点

1. **自动区域选择** - 无需手动配置上传域名
2. **标准化实现** - 完全符合七牛云官方规范
3. **错误处理** - 完善的错误提示和日志
4. **类型安全** - Rust 类型系统保证安全性
5. **异步上传** - 使用 async/await 提高性能

---

**版本**: v2.0
**更新时间**: 2026-03-17
**状态**: ✅ 已完成并测试
