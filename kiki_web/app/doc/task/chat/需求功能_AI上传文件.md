## 角色
你是Flutter 高级开发工程师，具有丰富的DDD架构和GetX状态管理经验，UI设计功能

## 任务目标

在dify_chat的聊天页面右侧ChatWindowPanel，利用现有的上传图片和上传文件按钮，实现统一的文件上传功能

### 核心功能需求

#### 1. 现有按钮集成
- **现有按钮位置**：`ChatWindowPanel` → `_ComposerBar` → `_ComposerActionButton`
- **上传图片按钮**：
  - 图标：`Icons.image_outlined`
  - 标签：'上传图片'
  - 当前方法：`_showComingSoon(context, '图片上传')`
- **上传文档按钮**：
  - 图标：`Icons.description_outlined`  
  - 标签：'上传文档'
  - 当前方法：`_showComingSoon(context, '文档上传')`
- **集成策略**：将 `_showComingSoon` 方法替换为实际的上传功能调用

#### 2. 方法名沿用方案
```dart
// 将现有的 _showComingSoon 方法改造为实际功能
void _showComingSoon(BuildContext context, String featureName) {
  if (featureName == '图片上传') {
    _handleImageUpload(context);
  } else if (featureName == '文档上传') {
    _handleDocumentUpload(context);
  }
}

// 或者直接替换调用
_ComposerActionButton(
  icon: Icons.image_outlined,
  label: '上传图片',
  onTap: () => _handleImageUpload(context),
),
_ComposerActionButton(
  icon: Icons.description_outlined,
  label: '上传文档',
  onTap: () => _handleDocumentUpload(context),
),
```

#### 2. 统一上传对话框功能
- **双模式支持**：
  - **图片模式**：支持 jpg, jpeg, png, gif, webp
  - **文档模式**：支持 PDF, Word(.doc/.docx), Excel(.xls/.xlsx), PPT(.ppt/.pptx), EPUB, Mobi, txt, Key(.key), Numbers(.numbers), JSON
- **智能预览**：
  - 图片文件：显示缩略图预览
  - 文档文件：显示文件图标和基本信息
- **文件信息显示**：文件名、大小、格式、最后修改时间
- **上传进度**：统一的进度条和百分比显示
- **操作控制**：取消、删除已选文件、确认上传
- **错误处理**：格式不支持、大小超限、上传失败等提示

#### 3. 模式切换机制
```dart
enum UploadMode {
  image,    // 图片上传模式
  document  // 文档上传模式
}

// 调用示例
UploadFileDialog.show(
  context,
  mode: UploadMode.image,
  maxFileSize: 10 * 1024 * 1024,
)
```

#### 3. 技术实现要求
- **API集成**：调用真实的文件上传API，并增强现有API层
- **状态管理**：使用GetX管理上传状态、进度、错误信息
- **文件处理**：支持文件选择、压缩、格式验证
- **响应处理**：处理上传成功后的文件URL返回
- **现有架构增强**：基于ChatDifyApi和RequestManager扩展上传功能

#### 4. 独立模块结构
```
lib/presentation/pages/chat_dify/
├── chat_dify_upload_file/               # 独立统一上传模块
│   ├── controllers/                     # 控制器层
│   │   └── upload_file_controller.dart
│   ├── models/                          # 数据模型层
│   │   ├── upload_file_data.dart
│   │   ├── upload_progress_data.dart
│   │   └── upload_mode.dart
│   ├── services/                        # 业务服务层
│   │   └── upload_file_service.dart
│   ├── widgets/                         # UI组件层
│   │   ├── upload_file_dialog.dart
│   │   ├── file_preview_widget.dart
│   │   ├── upload_progress_widget.dart
│   │   ├── file_info_widget.dart
│   │   └── mode_selector_widget.dart
│   └── examples/                        # 使用示例
│       └── upload_file_usage_example.dart
```

## 已知上下文
📑 **接口文档参考**
• 上传文档API： → doc/features/chat/chat_dify/上传文件_API.md

📑 **相关技术参考**
• 文件选择：file_picker 插件
• 图片处理：image 插件
• 文档处理：支持多种格式识别和验证
• 文件上传：http multipart 请求
• 进度监听：dio 或 http 请求进度回调
• MIME类型检测：mime 插件

## API集成架构要求

### ChatDifyApi 扩展要求
需要在现有的 `ChatDifyApi` 类中新增以下文件上传方法：

```dart
// 文件上传方法
static Future<ApiResponse<UploadFileResponse>> uploadFile({
  required String difyUserId,
  required File file,
  required String fileType, // 'image' 或 'document'
  Function(int sent, int total)? onSendProgress,
}) async {
  // 实现文件上传逻辑
  // 支持进度回调
  // 返回上传结果包含文件URL
}

// 批量文件上传方法
static Future<ApiResponse<List<UploadFileResponse>>> uploadMultipleFiles({
  required String difyUserId,
  required List<File> files,
  required String fileType,
  Function(int sent, int total)? onSendProgress,
}) async {
  // 实现批量上传逻辑
}
```

### RequestManager 增强要求
如果现有的 `RequestManager` 不支持文件上传和进度监听，需要增强：

```dart
// 在 RequestManager 中添加文件上传支持
Future<ApiResponse<T>> uploadFile<T>({
  required String endpoint,
  required File file,
  required Map<String, dynamic> fields,
  Function(int sent, int total)? onSendProgress,
  T Function(Map<String, dynamic>)? fromJson,
}) async {
  // 实现multipart文件上传
  // 支持进度回调
  // 统一错误处理
}
```

### 数据模型定义
需要定义以下响应模型：

```dart
class UploadFileResponse {
  final String fileId;
  final String fileName;
  final String fileUrl;
  final String fileType;
  final int fileSize;
  final DateTime uploadTime;
  
  // fromJson, toJson 等标准方法
}
```

## 约束与规范

### 开发架构规范
• **基础要求**：所有基础开发要求需动态读取：doc/prompt/base_*.md
• **团队指南**：必须遵循团队开发指南：doc/framework/新功能开发指南标准_20250916.md  
• **状态管理**：使用GetX状态管理，Controller放在独立controllers目录
• **数据模型**：数据模型放在独立models目录
• **业务逻辑**：业务逻辑通过services层处理
• **API调用**：集成现有RequestManager进行API调用
• **兼容性**：不修改现有聊天功能逻辑

### UI 设计规范
• **设计系统**：样式、颜色、布局遵循：doc/prompt/ui_prompt_info.md
• **对话框设计**：居中模态对话框设计，支持响应式布局
• **交互反馈**：
  - 文件选择按钮hover效果
  - 拖拽上传区域（可选）
  - 删除按钮确认提示
  - 上传中禁用操作
• **状态显示**：
  - 文件选择状态
  - 上传进度状态
  - 成功/失败状态
• **错误处理**：统一的错误提示样式和用户友好的错误信息

### **功能独立性**（核心原则）
- **完全独立**：功能完全独立，不依赖现有逻辑  
- **零修改**：不修改任何现有文件，只新增独立模块
- **参数集成**：通过参数控制集成，不侵入现有流程
- **模块化**：单独的服务层、控制器、组件，保证模块化
- **可测试性**：可以独立开发、测试、部署，不影响原有功能

### 文件处理规范
• **图片格式**：jpg, jpeg, png, gif, webp
• **文档格式**：
  - 办公文档：PDF, Word(.doc/.docx), Excel(.xls/.xlsx), PPT(.ppt/.pptx)
  - 电子书：EPUB, Mobi
  - 文本文件：txt, JSON
  - Apple格式：Key(.key), Numbers(.numbers)
• **文件大小限制**：
  - 图片文件：单个最大10MB
  - 文档文件：单个最大50MB
• **处理策略**：
  - 图片：大图自动压缩到合适尺寸
  - 文档：保持原始格式，验证完整性
• **安全验证**：文件类型验证，MIME类型检测，防止恶意文件上传

### 关键技术点
• **完全独立性**：新功能零依赖现有聊天，可独立开发和部署
• **双模式设计**：统一对话框支持图片和文档两种上传模式
• **智能文件处理**：根据文件类型自动选择处理策略
• **统一上传管理**：支持上传进度、取消上传、重试机制
• **状态同步**：上传状态与UI实时同步
• **错误恢复**：网络异常时的重试和恢复机制
• **现有集成**：利用现有按钮入口，无需修改现有UI结构

### 实现要求
• **禁止模拟**：明确禁止模拟代码："不要使用任何模拟、延迟或假数据"
• **真实实现**：要求具体实现："必须调用真实的API方法"
• **调试支持**：要求测试验证："提供可验证的调试日志"
• **成功标准**：明确成功标准："应该能看到真实的API响应和文件上传成功"
• **异常处理**：完整的错误处理和用户反馈机制

### 集成方式
```dart
// 方案1：改造现有 _showComingSoon 方法
void _showComingSoon(BuildContext context, String featureName) {
  if (featureName == '图片上传') {
    _handleImageUpload(context);
  } else if (featureName == '文档上传') {
    _handleDocumentUpload(context);
  } else {
    // 保留原有的 Coming Soon 提示逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName 功能开发中，敬请期待'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// 具体的上传处理方法
Future<void> _handleImageUpload(BuildContext context) async {
  final result = await UploadFileDialog.show(
    context,
    mode: UploadMode.image,
    maxFileSize: 10 * 1024 * 1024, // 10MB
    title: '上传图片',
  );
  
  if (result != null) {
    _processUploadedFile(result);
  }
}

Future<void> _handleDocumentUpload(BuildContext context) async {
  final result = await UploadFileDialog.show(
    context,
    mode: UploadMode.document,
    maxFileSize: 50 * 1024 * 1024, // 50MB
    title: '上传文档',
  );
  
  if (result != null) {
    _processUploadedFile(result);
  }
}

// 方案2：直接替换按钮的 onTap 方法（推荐）
_ComposerActionButton(
  icon: Icons.image_outlined,
  label: '上传图片',
  onTap: () => _handleImageUpload(context),
),
_ComposerActionButton(
  icon: Icons.description_outlined,
  label: '上传文档',
  onTap: () => _handleDocumentUpload(context),
),
```

### 文件位置说明
- **目标文件**：`/lib/presentation/pages/chat_dify/chat_window_panel.dart`
- **目标类**：`_ComposerBar extends GetView<ChatDifyController>`
- **目标方法**：`_showComingSoon` (第701行附近)
- **按钮定义**：在 `build` 方法的 `Row` 中，包含两个 `_ComposerActionButton`

### 验收标准
• **功能完整**：
  - 支持图片上传模式（jpg, jpeg, png, gif, webp）
  - 支持文档上传模式（PDF, Word, Excel, PPT, EPUB, Mobi, txt, Key, Numbers, JSON）
  - 能够正确选择、预览、上传各类文件
• **集成完善**：成功集成到现有的上传文件按钮，无需修改现有UI
• **交互流畅**：上传进度实时显示，模式切换顺畅，操作响应及时
• **错误处理**：各种异常情况都有明确的用户提示，支持不同文件类型的错误处理
• **性能良好**：大文件上传不阻塞UI，支持取消操作，图片压缩合理
• **独立性**：可以独立运行，不影响现有聊天功能
• **扩展性**：易于添加新的文件格式支持，模式切换机制灵活

