## 角色
你是Flutter 高级开发工程师，具有丰富的DDD架构和GetX状态管理经验，UI设计功能

## 任务目标

**UploadFileDialog 文件上传功能已完成**，现需要在其基础上实现数据结构转换功能，将上传成功的文件组织成符合 Dify API 要求的格式，并集成到 ChatDifyController 的发送消息流程中。

### 🎯 核心功能流程
1. **UploadFileDialog 上传完成** → 获取 `file_id` 列表
2. **数据结构转换** → 组织成 Dify API 格式的文件引用数据
3. **回调传递数据** → 通过 `onUploadSuccess` 回调传递结构化数据给 ChatDifyController
4. **ChatDifyController 暂存** → 接收并暂存文件数据，等待发送消息
5. **集成发送消息** → 在第一次发送消息时附加到 `files` 参数
6. **发送完成清理** → 清空文件数据，避免重复发送

### 开发架构规范
⚠️ **独立性原则** - 严禁修改现有 UploadFileDialog 和 ChatDifyController 核心逻辑

• 所有基础开发要求需动态读取：doc/prompt/base_*.md
• 必须遵循团队开发指南：doc/framework/新功能开发指南标准_20250916.md  
• 使用GetX状态管理，Controller放在独立 controllers目录
• 数据模型放在独立 models目录
• 业务逻辑通过services层处理
• 集成现有RequestManager进行API调用
• **通过回调和参数传递进行集成，不侵入现有代码**

### 实现要求
- **禁止模拟代码**："不要使用任何模拟、延迟或假数据"
- **真实API调用**："必须调用真实的API方法"
- **测试验证**："提供可验证的调试日志"
- **成功标准**："应该能看到真实的API响应"

### 📋 具体技术需求

#### 1. **文件上传接口**（已完成）
📑 接口文档参考：`doc/task/chat/chat_dify/上传文件_API.md`
- UploadFileDialog 已实现文件上传功能
- 获取返回的 `id` 作为 `file_id`

#### 2. **数据结构转换**（待实现）
**目标格式**：符合 Dify API 发送消息接口的 `files` 参数格式

**文件访问URL格式**：
```
{ChatDifyApi.defaultBaseUrl}/files/{file_id}/file
```
即：`http://117.50.199.230/v1/files/{file_id}/file`

**输出数据结构**：
```json
{
  "files": [
    {
      "type": "image",  // 图片用 "image"，文档用 "file"
      "transfer_method": "remote_url",
      "url": "http://117.50.199.230/v1/files/{file_id}/file"
    }
  ],
  "formattedQuery": "[文件名1](file-{file_id_1})\n[文件名2](file-{file_id_2})"
}
```

#### 3. **集成要求**（待实现）
- **通过回调传递数据**：在 UploadFileDialog 构造函数中添加 `onUploadSuccess` 回调参数
- **保持原有返回值**：UploadFileDialog 的 `show()` 方法返回值保持 `List<String>?` 不变
- **ChatDifyController 接收**：通过回调函数接收结构化文件数据并暂存
- **发送消息集成**：在 `submitMessage` 中检查是否有待发送文件
- **文件参数附加**：将文件数据附加到发送消息的 `files` 参数
- **发送后清理**：消息发送成功后清空文件数据

**回调函数签名**：
```dart
typedef OnUploadSuccessCallback = void Function(DifyFileReference fileReference);

// UploadFileDialog 构造函数添加：
const UploadFileDialog({
  // ... 现有参数
  this.onUploadSuccess,  // 新增回调参数
});

final OnUploadSuccessCallback? onUploadSuccess;
```

**调用示例**：
```dart
// 在 ChatWindowPanel 中调用
UploadFileDialog.show(
  context,
  mode: UploadMode.image,
  maxFileSize: 1024 * 1024,
  title: '上传图片',
  difyUserId: controller.difyUserId!,
  onUploadSuccess: (fileReference) {
    // 回调中处理文件数据
    controller.setUploadedFiles(fileReference);
  },
);
```

#### 4. **文件类型判断规则**
```dart
// 图片类型 → type: "image"
const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];

// 文档类型 → type: "file"  
const docExtensions = ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx', 'ppt', 'pptx'];
```

#### 5. **关键约束**
- `user` 字段必须在上传和发消息时保持一致
- 文件引用必须使用 `ChatDifyApi.defaultBaseUrl` 构建URL
- `type` 字段必须根据文件扩展名正确设置
- Markdown 引用格式：`[原始文件名](file-{file_id})`
- 支持多文件上传和引用

#### 6. **错误处理**
- 上传失败的文件不应包含在返回数据中
- 无效文件ID的处理机制
- 网络异常时的重试策略
