你是一个 Flutter 高级开发和架构师。
- 你要严格遵循我的需求文档和开发任务清单。
- 我会逐个给你任务编号，你只需要完成当前任务的代码输出。
- 完成后等待下一个任务，不要越界提前实现。天页面开发需求，

⸻

ChatDify 聊天页面开发需求（最终版）

🎯 功能需求
	1.	页面布局
	•	左侧：AI 聊天会话列表（可滚动选择）
	•	右侧：聊天窗口
	•	展示当前会话历史消息
	•	如果没有历史消息 → 进入新会话模式，显示空态提示（如“暂无消息，请开始对话”）
	2.	页面入口
	•	从作业页面跳转进入聊天页面
	•	路由参数：

{
  "studentUid": studentUid,
  "teacherUid": selectedTeacher.uid,
  "assignmentId": assignment.id,
  "assignmentName": assignment.title
}


	3.	Dify 用户标识规则
	•	Dify 的 userId = studentUid + assignmentId
	•	示例：
	•	studentUid = stu_001
	•	assignmentId = ass_1001
	•	userId = stu_001_ass_1001
	4.	聊天窗口功能
	•	支持上传图片、上传文档、消息输入框、发送按钮
	•	消息内容支持：Markdown 表格、代码高亮
	•	首次进入新会话 → 聊天区为空态，只有用户输入后才开始显示流式消息

⸻

⚙️ 技术要求
	1.	基础框架
	•	markdown 插件：flutter_markdown ^0.7.7
	•	高亮组件：flutter_highlight ^0.7.0
	•	弹框组件：shirne_dialog ^4.8.3
	•	左右两部分必须实现为 独立 Widget 页面
	•	所有代码生成在：presentation/pages/chat_dify_new/
	2.	消息渲染
	•	用户消息：普通文本
	•	AI 回复：支持 Markdown + 代码高亮
	3.	消息流式处理
	•	调用 Dify API，采用 SSE (Server-Sent Events) 获取流式消息
	•	Flutter 使用 StreamBuilder（或等效方案）逐步更新消息
	•	用户发消息后：
	•	立即插入一条“AI 占位消息”
	•	随着 SSE 流式数据逐步更新内容
	4.	API 接口类
	•	所有方法统一放在 ChatDifyApi 类 ,可以借鉴ChatApi类的使用方法
	•	新增/修改方法必须在此类中实现，并保持兼容现有逻辑
	•	接口实现参考已有 ChatPage（简单 Dify 聊天页面）
	•	核心方法必须带功能注释

⸻

📑 接口文档参考
	•	获取会话列表 → doc/features/chat/获取会话列表_API.md
	•	获取当前会话历史消息 → doc/features/chat/获取会话历史消息_API.md
	•	发送对话消息 → doc/features/chat/发送对话消息_API.md

⸻

📐 约束与规范
	1.	页面架构
	•	左侧：ConversationListPanel
	•	右侧：ChatWindowPanel
	•	两部分必须独立成 Widget 页面
	2.	开发架构规范
	•	动态读取：doc/prompt/base_*.md（基础开发规范）
	•	遵循：doc/framework/新功能开发指南标准_20250916.md
	3.	UI 设计规范
	•	样式、颜色、布局 → 遵循 doc/prompt/ui_prompt_ui.md
	4.	限制
	•	不得修改已有逻辑功能，只能新增与扩展
	•	保证 Dify userId 规则固定为：studentUid + assignmentId

⸻

✅ 输出要求
	•	新建 presentation/pages/chat_dify/ 下的页面文件
	•	实现两个独立 Widget：ConversationListPanel、ChatWindowPanel
	•	修改/新增 ChatApi 方法，支持 Dify SSE 流式消息，附功能注释
	•	空态处理：当无历史消息时 → 显示提示 UI，发送第一条消息时新建会话
	•	所有代码符合 UI 规范与架构约束

⸻

📋 ChatDify 前端任务卡片清单

⸻

🟩 任务卡片 1：页面结构搭建

目标
	•	新建页面目录与容器页面。
	•	支持从作业页跳转进入，接收参数。

说明
	•	新建目录：presentation/pages/chat_dify/
	•	实现 ChatDifyPage，左右两部分布局。
	•	确保路由注册在 AppRoutes 与 AppConstants。

验收标准
	•	路由跳转成功，参数正确传递到页面。
	•	左右布局能正常占位。

⸻

🟩 任务卡片 2：左侧会话列表（ConversationListPanel）

目标
	•	展示 AI 会话列表。

说明
	•	独立 Widget：ConversationListPanel。
	•	横向滚动，可选择会话。
	•	支持选中态（高亮）。
	•	空态 → 显示“暂无会话”。

验收标准
	•	可滚动展示所有会话。
	•	默认选中第一个。
	•	切换时右侧刷新。

⸻

🟩 任务卡片 3：右侧聊天窗口（ChatWindowPanel）

目标
	•	展示当前会话消息。

说明
	•	独立 Widget：ChatWindowPanel。
	•	历史消息：Markdown + 代码高亮。
	•	空态 → “新会话，请开始聊天”。
	•	输入区：文本框、上传图片/文档按钮、发送按钮。
	•	发送消息时插入“AI 占位消息”，等待流式数据填充。

验收标准
	•	历史消息能正常渲染。
	•	新会话显示空态。
	•	发送后出现占位消息，并随 SSE 更新。

⸻

🟩 任务卡片 4：API 集成与状态管理

目标
	•	接入已有 ChatApi。

说明
	•	在 ChatApi 新增：获取会话列表、获取历史消息、发送消息(SSE)。
	•	Controller 使用 GetX，管理会话与消息状态。
	•	Dify 的 userId = studentUid + assignmentId。

验收标准
	•	所有调用通过 ChatApi。
	•	状态更新 → UI 自动刷新。
	•	userId 规则固定。

⸻

🟩 任务卡片 5：UI 与交互优化

目标
	•	对齐设计规范。

说明
	•	Markdown 渲染：flutter_markdown。
	•	代码高亮：flutter_highlight。
	•	上传附件：shirne_dialog 弹框。
	•	样式对齐 doc/prompt/ui_prompt_ui.md。

验收标准
	•	UI 元素符合规范（圆角、颜色、间距）。
	•	上传附件流程可触发。
	•	AI 回复样式统一。

⸻

🟩 任务卡片 6：测试与验收

目标
	•	保证功能完整性。

说明
	•	Widget 测试：ConversationListPanel / ChatWindowPanel 渲染与交互。
	•	集成测试：从作业页跳转 → 默认加载会话 → 新会话流程。
	•	流式 SSE 测试：发送消息 → 占位 → 实时更新。

验收标准
	•	测试覆盖主要交互。
	•	正常 / 空态 / 错误场景均能展示。

⸻

