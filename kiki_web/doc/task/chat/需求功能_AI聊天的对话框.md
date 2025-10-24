## 角色
你是Flutter 高级开发工程师，具有丰富的DDD架构和GetX状态管理经验，UI设计功能

## 任务目标

在dify_chat的聊天页面右侧ChatWindowPanel

### 开发架构规范
⚠️ **独立性原则** - 严禁修改现有文件，保证功能完全独立

• 所有基础开发要求需动态读取：doc/prompt/base_*.md
• 必须遵循团队开发指南：doc/framework/新功能开发指南标准_20250916.md  
• 使用GetX状态管理，Controller放在独立 controllers目录
• 数据模型放在独立 models目录
• 业务逻辑通过services层处理
• 集成现有RequestManager进行API调用
• **绝对不修改现有聊天功能逻辑** - 只新增独立模块
• 通过参数控制和事件回调进行集成，不侵入现有代码Panel中实现研究定义对话框功能。

### 实现要求：
明确禁止模拟代码："不要使用任何模拟、延迟或假数据"
要求具体实现："必须调用真实的API方法"
要求测试验证："提供可验证的调试日志"
明确成功标准："应该能看到真实的API响应"


### 核心功能需求

1. **触发条件**（按优先级判断）：
   - 优先检查外部传递的参数控制是否弹窗（默认为true）
   - 当前聊天会话没有历史记录时自动弹出
   - 用户进入新聊天页面时弹出

2. **对话框行为**：
   - 居中模态对话框，用户可以选择填写或取消
   - 提供取消按钮，允许用户跳过研究定义直接进入聊天
   - 所有字段为必填项，每个字段限制200字符
   - 填写完成后点击确认按钮，将数据作为inputs发送给API接口
   - 点击取消按钮，直接进入普通聊天模式

3. **数据收集字段**：
   ```json
   {
     "research_question": "研究问题内容",
     "priori_hypothesis": "先验假设内容", 
     "prejudice_list": "个人偏见清单内容",
     "study_goal": "学习目标内容",
     "research_title": "研究题目内容"
   }
   ```

4. **参数控制**：
   - 路由跳转时通过Map传递`showDefineDialog`参数（默认true）
   - ChatDifyPageArguments中的showDefineDialog字段默认值为true
   - ChatDifyController在onInit()中用`ChatDifyPageArguments.from(Get.arguments)`解析参数
   - 通过getter方式获取：`bool get shouldShowDefineDialog => showDefineDialog ?? true`
   - 功能完全独立，不依赖现有聊天逻辑

5. **功能独立性**（核心原则）：
   - 新功能完全独立，零依赖现有聊天逻辑
   - 不修改任何现有文件，只新增独立模块
   - 通过参数控制集成，不海取现有流程
   - 单独的服务层、控制器、组件，保证模块化
   - 可以独立开发、测试、部署，不影响原有功能

⸻
## 已知上下文
📑 接口文档参考
• 发送对话消息 → doc/features/chat/发送对话消息_API.md
 

## 约束与规范

### 目录规范
功能代码独立目录：`chat_dify/chat_dify_define_dialog/`
```
lib/presentation/pages/chat_dify/chat_dify_define_dialog/
├── controllers/
│   └── chat_define_controller.dart          # GetX控制器
├── widgets/
│   ├── chat_define_dialog.dart              # 主对话框组件
│   ├── chat_define_form.dart                # 表单组件
│   └── chat_define_field_widget.dart        # 单个字段组件
├── models/
│   └── chat_define_data.dart                # 数据模型
└── services/
    └── chat_define_service.dart             # 业务服务层
```

### 页面架构
对话框表单结构：
```
研究定义对话框
├── 标题："研究定义设置"
├── 表单区域
│   ├── 研究问题 (research_question) [必填|删除图标|200字符]
│   ├── 先验假设 (priori_hypothesis) [必填|删除图标|200字符] 
│   ├── 个人偏见清单 (prejudice_list) [必填|删除图标|200字符]
│   ├── 学习目标 (study_goal) [必填|删除图标|200字符]
│   └── 研究题目 (research_title) [必填|删除图标|200字符]
└── 操作区域
    ├── 取消按钮 [关闭对话框，直接进入普通聊天]
    └── 确认按钮 [所有字段必填后才可点击，提交研究定义]
```

### 开发架构规范
• 所有基础开发要求需动态读取：doc/prompt/base_*.md
• 必须遵循团队开发指南：doc/framework/新功能开发指南标准_20250916.md  
• 使用GetX状态管理，Controller放在独立controllers目录
• 数据模型放在独立models目录
• 业务逻辑通过services层处理
• 集成现有RequestManager进行API调用
• 不修改现有聊天功能逻辑

### UI 设计规范
• 样式、颜色、布局遵循：doc/prompt/ui_prompt_info.md
• 居中模态对话框设计
• 每个输入字段包含删除图标功能
• 字符计数显示
• 统一的错误提示样式
• 按钮禁用/启用状态视觉反馈

### 集成方式
```dart
// 1. 路由跳转时传递Map参数
Get.toNamed(
  AppConstants.routeChatDify,
  arguments: {
    'studentUid': assignment.studentUid,
    'teacherUid': teacherUid,
    'assignmentId': assignment.assignmentId,
    'assignmentName': assignment.assignmentTitle,
    'showNewTopicAction': false,
    'showDefineDialog': true,  // 默认true，控制研究定义对话框
  },
);

// 2. ChatDifyController中独立的参数解析和判断逻辑
class ChatDifyController extends GetxController {
  ChatDifyPageArguments? _arguments;
  
  @override
  void onInit() {
    super.onInit();
    // 使用ChatDifyPageArguments.from()解析Map参数
    _arguments = ChatDifyPageArguments.from(Get.arguments);
    
    // 独立的对话框检查逻辑，不依赖现有流程
    _checkAndShowDefineDialog();
  }
  
  // 现有getter不变
  ChatDifyPageArguments? get arguments => _arguments;
  String? get studentUid => _arguments?.studentUid;
  String? get teacherUid => _arguments?.teacherUid;
  String? get assignmentId => _arguments?.assignmentId;
  String? get assignmentName => _arguments?.assignmentName;
  String? get difyUserId => _arguments?.difyUserId;
  
  // 新增的独立功能 getter
  bool? get showDefineDialog => _arguments?.showDefineDialog;
  bool get shouldShowDefineDialog => showDefineDialog ?? true;  // 默认true
  
  bool get allowManualNewTopic => _arguments?.showNewTopicAction == true;
}

// 3. 独立的对话框触发逻辑（完全独立，不依赖现有流程）
void _checkAndShowDefineDialog() {
  // 1. 首先检查参数控制（默认为true）
  if (!shouldShowDefineDialog) return;
  
  // 2. 检查是否有历史记录（独立判断）
  if (conversations.isNotEmpty) return;
  
  // 3. 显示研究定义对话框（独立功能）
  _showChatDefineDialog();
}

// 4. 独立的对话框结果处理
void _onDefineDialogResult(ChatDefineData? defineData) {
  if (defineData != null) {
    // 用户填写了研究定义，启动研究模式
    _startResearchMode(defineData);
  } else {
    // 用户取消，保持普通聊天模式（不作任何操作）
    // 现有聊天流程不受影响
  }
}

// 5. 独立的研究模式启动
void _startResearchMode(ChatDefineData defineData) {
  // 调用独立的研究服务
  // 不修改现有聊天逻辑，只添加研究上下文
}
```

### API集成方式
```dart
// 在ChatDifyApi中使用现有的sendMessageStream方法
class ChatDefineService {
  final ChatDifyApi _chatDifyApi = ChatDifyApi();
  
  /// 发送研究定义数据并开始对话
  Stream<String> sendDefineDataAndStartChat({
    required ChatDefineData defineData,
    required String user,
    required String initialQuery,
  }) {
    // 将研究定义数据转换为inputs格式
    final inputs = defineData.toInputs();
    
    // 调用现有的sendMessageStream方法
    return _chatDifyApi.sendMessageStream(
      query: initialQuery,           // 初始问题
      user: user,                   // 用户标识
      inputs: inputs,               // 研究定义数据作为inputs
      conversationId: null,         // 新对话，无conversationId
    );
  }
  
  /// 普通聊天模式（用户点击取消按钮时）
  Stream<String> startNormalChat({
    required String query,
    required String user,
  }) {
    // 不传递研究定义inputs，进入普通聊天模式
    return _chatDifyApi.sendMessageStream(
      query: query,
      user: user,
      inputs: null,                 // 无研究定义数据
      conversationId: null,         // 新对话
    );
  }
}

// ChatDefineData模型的toInputs方法
class ChatDefineData {
  final String researchQuestion;
  final String prioriHypothesis; 
  final String prejudiceList;
  final String studyGoal;
  final String researchTitle;
  
  Map<String, dynamic> toInputs() {
    return {
      'research_question': researchQuestion,
      'priori_hypothesis': prioriHypothesis,
      'prejudice_list': prejudiceList,
      'study_goal': studyGoal,
      'research_title': researchTitle,
    };
  }
}
```

### 数据流转
```
路由跳转(Map参数含showDefineDialog) → 
ChatDifyController.onInit()中用ChatDifyPageArguments.from()解析 → 
ChatDifyController.shouldShowDefineDialog检查参数 → 
检查conversations是否为空 → 显示研究定义对话框 → 
┌─ 用户填写表单并点击确认 → ChatDefineController验证 → 
│  ChatDefineService.sendDefineDataAndStartChat() → 
│  调用ChatDifyApi.sendMessageStream(含inputs) → 开始研究对话
└─ 用户点击取消按钮 → ChatDefineService.startNormalChat() → 
   调用ChatDifyApi.sendMessageStream(无inputs) → 开始普通聊天
```

### 关键技术点
1. **完全独立性**：新功能零依赖现有聊天逻辑，可独立开发和部署
2. **默认启用**：`showDefineDialog`默认为true，新用户默认享受研究模式
3. **类型安全**：使用`ChatDifyPageArguments.from(Get.arguments)`解析Map参数
4. **模块化设计**：独立的服务层、控制器、组件，保证可维护性
5. **API复用**：利用现有ChatDifyApi.sendMessageStream，通过inputs扩展
6. **状态管理**：独立的GetX控制器管理对话框状态和表单验证
7. **非侵入式**：通过参数和事件集成，不侵入现有代码结构
