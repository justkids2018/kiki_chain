use anyhow::{Context, Result};
use reqwest::multipart;
use uuid::Uuid;
use qiniu_sdk::upload_token::{UploadPolicy, credential::Credential};
use std::time::Duration;

/// 七牛云存储服务
pub struct QiniuService {
    access_key: String,
    secret_key: String,
    bucket: String,
    domain: String,
}

impl QiniuService {
    /// 创建七牛云服务实例
    pub fn new(access_key: String, secret_key: String, bucket: String, domain: String) -> Self {
        Self {
            access_key,
            secret_key,
            bucket,
            domain,
        }
    }

    /// 从环境变量创建实例
    pub fn from_env() -> Result<Self> {
        let access_key = std::env::var("QINIU_ACCESS_KEY")
            .context("QINIU_ACCESS_KEY not found in environment")?;
        let secret_key = std::env::var("QINIU_SECRET_KEY")
            .context("QINIU_SECRET_KEY not found in environment")?;
        let bucket =
            std::env::var("QINIU_BUCKET").context("QINIU_BUCKET not found in environment")?;
        let domain =
            std::env::var("QINIU_DOMAIN").context("QINIU_DOMAIN not found in environment")?;

        Ok(Self::new(access_key, secret_key, bucket, domain))
    }

    /// 获取上传区域
    pub async fn get_upload_region(&self) -> Result<String> {
        // 如果环境变量中指定了上传区域，直接使用
        if let Ok(region) = std::env::var("QINIU_UPLOAD_REGION") {
            let upload_url = match region.as_str() {
                "z0" => "https://up-z0.qiniup.com",
                "z1" => "https://up-z1.qiniup.com",
                "z2" => "https://up-z2.qiniup.com",
                "na0" => "https://up-na0.qiniup.com",
                "as0" => "https://up-as0.qiniup.com",
                _ => "https://up.qiniup.com",
            };
            return Ok(upload_url.to_string());
        }

        // 否则自动查询 Bucket 所在区域
        let client = reqwest::Client::new();
        let url = format!("https://uc.qiniuapi.com/v4/query?ak={}&bucket={}",
            self.access_key, self.bucket);

        let response = client
            .get(&url)
            .send()
            .await
            .context("Failed to query upload region")?;

        if !response.status().is_success() {
            // 如果查询失败，使用默认的上传域名
            return Ok("https://up.qiniup.com".to_string());
        }

        let data: serde_json::Value = response.json().await?;

        // 从响应中提取上传域名
        if let Some(hosts) = data["hosts"].as_array() {
            if let Some(host) = hosts.first() {
                if let Some(up_host) = host["up"].as_object() {
                    if let Some(domains) = up_host["domains"].as_array() {
                        if let Some(domain) = domains.first() {
                            if let Some(domain_str) = domain.as_str() {
                                return Ok(format!("https://{}", domain_str));
                            }
                        }
                    }
                }
            }
        }

        // 默认使用华东区域
        Ok("https://up.qiniup.com".to_string())
    }

    /// 生成简单的上传凭证（允许上传到整个 bucket）
    pub fn generate_simple_upload_token(&self) -> String {
        let credential = Credential::new(&self.access_key, &self.secret_key);
        let upload_token = UploadPolicy::new_for_bucket(&self.bucket, Duration::from_secs(3600))
            .build_token(credential, Default::default());
        upload_token.to_string()
    }

    /// 获取 CDN 域名
    pub fn get_domain(&self) -> &str {
        &self.domain
    }

    /// 上传图片
    ///
    /// # Arguments
    /// * `file_data` - 图片二进制数据
    /// * `file_name` - 原始文件名（用于提取扩展名）
    /// * `folder` - 存储文件夹（如 "categories", "scenes"）
    ///
    /// # Returns
    /// 返回图片的完整 CDN URL
    pub async fn upload_image(
        &self,
        file_data: Vec<u8>,
        file_name: &str,
        folder: &str,
    ) -> Result<String> {
        use tracing::info;

        // 生成唯一文件名，统一放在 kiki/ 目录下
        let extension = std::path::Path::new(file_name)
            .extension()
            .and_then(|s| s.to_str())
            .unwrap_or("jpg");
        let unique_name = format!("kiki/{}/{}.{}", folder, Uuid::new_v4(), extension);
        info!("📤 生成文件名: {}", unique_name);

        // 获取上传区域
        let upload_url = self.get_upload_region().await?;
        info!("📍 上传域名: {}", upload_url);

        // 生成上传凭证
        let token = self.generate_simple_upload_token();
        info!("🔑 上传凭证: {}...", &token[..50]);

        // 构建 multipart 表单
        let part = multipart::Part::bytes(file_data)
            .file_name(file_name.to_string())
            .mime_str("image/*")?;

        let form = multipart::Form::new()
            .text("key", unique_name.clone())
            .text("token", token)
            .part("file", part);

        info!("📤 开始上传到七牛云...");

        // 发送上传请求
        let client = reqwest::Client::new();
        let response = client
            .post(&upload_url)
            .multipart(form)
            .send()
            .await
            .context("Failed to send upload request")?;

        let status = response.status();
        info!("📥 七牛云响应状态: {}", status);

        if !status.is_success() {
            let error_text = response.text().await.unwrap_or_default();
            info!("❌ 七牛云错误: {}", error_text);
            anyhow::bail!("Upload failed: {}", error_text);
        }

        let response_text = response.text().await?;
        info!("✅ 七牛云响应: {}", response_text);

        // 返回 CDN URL
        let url = format!("https://{}/{}", self.domain, unique_name);
        info!("🎉 上传成功: {}", url);
        Ok(url)
    }
}
