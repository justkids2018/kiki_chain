## 角色
你是Flutter 高级开发工程师，具有丰富的DDD架构和GetX状态管理经验，专注于核心范畴对话框功能开发

## 任务目标

在dify_chat的聊天页面右侧ChatWindowPanel中实现核心范畴对话框功能。

### 开发架构规范
⚠️ **独立性原则** - 严禁修改现有文件，保证功能完全独立

• 所有基础开发要求需动态读取：doc/prompt/base_*.md
• 必须遵循团队开发指南：doc/framework/新功能开发指南标准_20250916.md  
• 使用GetX状态管理，Controller放在独立 controllers目录
• 数据模型放在独立 models目录
• 业务逻辑通过services层处理
• 集成现有RequestManager进行API调用
• **绝对不修改现有聊天功能逻辑** - 只新增独立模块
• 通过参数控制和事件回调进行集成，不侵入现有代码

### 实现要求：
明确禁止模拟代码："不要使用任何模拟、延迟或假数据"
要求具体实现："必须调用真实的API方法"
要求测试验证："提供可验证的调试日志"
明确成功标准："应该能看到真实的API响应"

## 核心功能需求

### 1. **触发条件**：
   - 在 `_ChatHeader` 中当选中"三级编码"时自动弹出核心范畴对话框
   - 调用弹框方法放到controller里面：`controller.handleSelectiveDialog(context)`
   - 从其他状态切换到三级编码(value=3)时触发

### 2. **核心范畴对话框功能**：
   - 用于收集核心范畴分析相关数据
   - 2个输入字段，每行一个标题和一个输入框
   - 实时验证和字符限制（200字符/字段）
   - 支持字段清空功能
   - 智能字符计数（聚焦时显示）

### 3. **数据收集字段**：
点击确认后返回下面的参数，作为inputs 参数发送消息，message="我已发送核心范畴信息"
```json
{
  "selective_coding": "用户输入的核心范畴内容",
  "proposition_assumption": "用户输入的命题假设内容"
}
```

### 4. **交互流程**：
   - 用户选择"三级编码" → 自动弹出核心范畴对话框
   - 用户填写2个字段的核心范畴数据
   - 点击确认按钮 → 将数据以JSON格式返回给controller
   - 自动发送消息："我已发送核心范畴信息" + inputs数据
   - 数据提交后立即关闭对话框，进入核心范畴分析聊天模式

### 5. **功能独立性**（核心原则）：
   - 新功能完全独立，零依赖现有聊天逻辑
   - 不修改任何现有文件，只新增独立模块
   - 通过参数控制集成，不侵入现有流程
   - 单独的服务层、控制器、组件，保证模块化
   - 可以独立开发、测试、部署，不影响原有功能

## 完整实现架构

### 目录结构
```
lib/presentation/pages/chat_dify/chat_dify_selective_dialog/
├── models/
│   └── selective_data.dart                   # 核心范畴数据模型
├── controllers/
│   └── selective_dialog_controller.dart      # 核心范畴对话框控制器
└── widgets/
    └── selective_dialog.dart                 # 核心范畴对话框UI组件
```

### 核心文件结构

#### 1. SelectiveData 数据模型 (`models/selective_data.dart`)
```dart
class SelectiveData {
  final String selectiveCoding;       // 核心范畴
  final String propositionAssumption; // 命题假设

  // 核心方法
  Map<String, dynamic> toInputs();  // 转换为API inputs格式
  bool get isComplete;              // 验证所有字段是否填写
  static Map<String, Map<String, String>> fieldConfigs; // 字段配置
}
```

#### 2. SelectiveDialogController 控制器 (`controllers/selective_dialog_controller.dart`)
```dart
class SelectiveDialogController extends GetxController {
  // 2个文本控制器 + 2个焦点节点
  // 2个字符计数Observable
  // 表单验证状态管理
  
  // 核心方法
  Future<SelectiveData?> submitForm();     // 提交表单
  void clearField(String fieldName);      // 清空指定字段
  SelectiveData getCurrentData();          // 获取当前数据
  void _validateForm();                    // 实时验证
}
```

#### 3. SelectiveDialog UI组件 (`widgets/selective_dialog.dart`)
```dart
class SelectiveDialog extends StatelessWidget {
  // 静态方法显示对话框
  static Future<SelectiveData?> show(BuildContext context);
  
  // UI构建方法
  Widget _buildHeader();                // 构建头部
  Widget _buildFormFields();           // 构建表单字段
  Widget _buildInputField();           // 构建单个输入字段
  Widget _buildButtons();              // 构建按钮区域
}
```

#### 4. ChatDifyController 集成 (`chat_dify_controller.dart`)
```dart
// 新增方法
Future<void> handleSelectiveDialog(BuildContext context);
void setSelectiveData(SelectiveData selectiveData);
void clearSelectiveData();

// 修改 submitMessage 方法支持自定义inputs
void submitMessage([String? content, Map<String, dynamic>? customInputs]);
```

## 开发迭代步骤

### 第一步：基础架构搭建
1. ✅ 创建独立目录结构
2. ✅ 实现 SelectiveData 数据模型
3. ✅ 实现 SelectiveDialogController 控制器
4. ✅ 创建基础 SelectiveDialog UI组件

### 第二步：表单功能实现
1. ✅ 2个输入字段的动态渲染
2. ✅ 实时字符计数功能
3. ✅ 表单验证逻辑
4. ✅ 字段清空功能
5. ✅ 提交和取消逻辑

### 第三步：集成到主聊天系统
1. ✅ 在 ChatDifyController 中添加 handleSelectiveDialog 方法
2. ✅ 修改 _ChatHeader 触发逻辑
3. ✅ 实现数据缓存和API集成
4. ✅ 自动消息发送机制

### 第四步：UI优化迭代
1. ✅ **Liquid Glass 设计系统集成**
   - 核心色彩：#00C37D
   - 边框圆角：按钮6px、输入框8px、对话框12px
   - 毛玻璃阴影效果

2. ✅ **聚焦状态优化**
   - 聚焦时显示绿色边框（#00C37D）
   - 微妙阴影效果：绿色光晕
   - 边框动态变化：1px → 2px

3. ✅ **字符计数简化**
   - 移除头部总体字符计数
   - 仅在输入框聚焦时显示单个字段计数
   - 流畅的200ms渐变动画

4. ✅ **按钮布局优化**
   - 固定宽度80px，取消Expanded拉伸
   - 右对齐布局，更符合操作习惯
   - 紧凑的12px按钮间距

5. ✅ **研究阶段切换器优化**
   - 轻量化选中状态：仅边框指示
   - 取消背景填充，保持白色背景
   - 精细边框：选中1.5px，未选中1px
   - 文字颜色统一：选中绿色，未选中灰色

### 第五步：完善细节体验
1. ✅ 对话框立即关闭机制
2. ✅ 成功提示消息
3. ✅ 错误处理和用户反馈
4. ✅ 加载状态显示
5. ✅ 响应式设计适配

## 字段详细配置

### 字段定义
| 字段名 | 显示名称 | 描述 | 字符限制 |
|--------|----------|------|----------|
| selective_coding | 核心范畴 | 选择性编码阶段确定的核心概念和范畴，代表研究现象的核心主题 | 200 |
| proposition_assumption | 命题假设 | 基于核心范畴提出的理论命题和假设，用于构建理论框架 | 200 |

### 字段详细配置

#### 核心范畴 (selective_coding)
- **显示名称**: "核心范畴"
- **输入提示**: "选择性编码阶段确定的核心概念和范畴，代表研究现象的核心主题"
- **字段类型**: 必填文本输入框
- **字符限制**: 200字符
- **功能**: 删除图标、字符计数

#### 命题假设 (proposition_assumption)
- **显示名称**: "命题假设"
- **输入提示**: "基于核心范畴提出的理论命题和假设，用于构建理论框架"
- **字段类型**: 必填文本输入框
- **字符限制**: 200字符
- **功能**: 删除图标、字符计数

### UI 设计规范
• 样式、颜色、布局遵循：doc/prompt/ui_prompt_info.md
• 居中模态对话框设计（600px宽度，最大500px高度）
• 每个输入字段包含删除图标功能
• **智能字符计数**：仅在聚焦时显示，避免UI过载
• **输入提示文本**：使用字段description作为placeholder
• **多行支持**：输入框支持多行文本（minLines: 3）
• **聚焦状态**：绿色边框 + 微妙阴影效果
• **按钮优化**：固定宽度，右对齐布局
• **轻量选中**：研究阶段切换器仅边框指示

### 关键技术点
1. **完全独立性**：新功能零依赖现有聊天逻辑，可独立开发和部署
2. **模块化设计**：独立的服务层、控制器、组件，保证可维护性
3. **API复用**：利用现有ChatDifyApi.sendMessageStream，通过inputs扩展核心范畴数据
4. **状态管理**：独立的GetX控制器管理对话框状态和表单验证
5. **非侵入式**：通过参数和事件集成，不侵入现有代码结构
6. **触发机制**：监听codeStatus变化，当值变为3（三级编码）时自动弹出
7. **即时反馈**：提交后立即关闭对话框，自动发送消息
8. **用户体验**：Liquid Glass设计系统，流畅动画，智能交互

### 集成方式
1. **Controller方法**：在ChatDifyController中添加`handleSelectiveDialog(BuildContext context)`方法
2. **状态监听**：在_ChatHeader的onTap回调中检测三级编码选择并调用controller方法
3. **数据传递**：通过submitMessage方法的customInputs参数传递核心范畴数据
4. **API集成**：在submitMessage时将核心范畴数据加入inputs参数传递给Dify API
5. **UI集成**：通过SelectiveDialog.show静态方法显示对话框，支持回调处理

### _ChatHeader 集成代码示例
```dart
// 当从其他状态切换到三级编码(value=3)时，自动弹出核心范畴对话框
if (previousValue != 3 && stage['value'] == 3) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    controller.handleSelectiveDialog(context);
  });
}
```

### ChatDifyController 集成方法
```dart
/// 处理核心范畴对话框
Future<void> handleSelectiveDialog(BuildContext context) async {
  final userId = difyUserId;
  if (userId == null) {
    Get.snackbar(
      '错误',
      '用户ID未找到，无法进行核心范畴分析',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
    );
    return;
  }

  try {
    final result = await SelectiveDialog.show(
      context,
      onSubmit: (selectiveData) {
        // 自动发送消息
        submitMessage("我已发送核心范畴信息", selectiveData.toInputs());
        // 显示成功消息
        Get.snackbar(
          '设置成功',
          '核心范畴参数已设置，正在发送消息...',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
        );
      },
    );
    
    // 如果用户取消了对话框，清除缓存数据
    if (result == null) {
      clearSelectiveData();
    }
  } catch (e) {
    Get.snackbar(
      '错误',
      '核心范畴对话框显示失败: ${e.toString()}',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
    );
  }
}
```

### 优化特色
- **设计系统合规**：完全遵循Liquid Glass设计规范
- **性能优化**：智能字符计数，避免不必要的UI更新
- **交互流畅**：200ms渐变动画，自然的状态转换
- **布局精准**：固定按钮宽度，精确的间距控制
- **状态清晰**：轻量化选中指示，清晰不突兀
- **简洁高效**：2个字段设计，专注核心范畴收集

## 实施验证

### 功能验证清单
- [ ] **架构独立性**：功能模块完全独立，不影响现有聊天功能
- [ ] **触发机制**：三级编码选择时自动弹出对话框
- [ ] **数据收集**：2个字段完整收集，实时验证
- [ ] **API集成**：数据正确传递给Dify API的inputs参数
- [ ] **用户体验**：流畅的交互动画，清晰的状态反馈
- [ ] **设计规范**：完全符合Liquid Glass设计系统
- [ ] **错误处理**：完善的异常处理和用户提示

### 技术债务和优化点
1. **性能优化**：智能字符计数，避免过度渲染
2. **用户体验**：一键清空、聚焦状态、流畅动画
3. **代码质量**：模块化设计，高内聚低耦合
4. **可维护性**：独立架构，便于后续扩展和维护

### 部署建议
1. **渐进发布**：功能独立性保证可以安全部署
2. **监控重点**：关注对话框打开率、完成率、API调用成功率
3. **用户反馈**：收集UI交互体验反馈，持续优化
4. **性能监控**：监控内存使用和渲染性能

## 总结

核心范畴对话框功能将完成完整的开发迭代，从基础架构搭建到UI优化提升：

**🎯 核心目标**：
- 完全独立的模块化架构
- 符合Liquid Glass设计系统的精美UI
- 流畅的用户交互体验
- 完善的API集成和数据处理
- 智能的状态管理和错误处理

**💡 技术亮点**：
- 非侵入式集成，零影响现有功能
- 响应式设计，适配多种屏幕尺寸
- 智能字符计数，避免UI过载
- 轻量化选中状态，清晰不突兀
- 即时反馈机制，提升用户体验
- 简洁高效的2字段设计

该功能为用户提供了专业的核心范畴数据收集界面，为AI助教提供了理论建构的核心信息，显著提升了学术研究辅助的专业性和有效性。