---
description: '奇奇漫游记项目专用 agent 模式'
model: Claude Sonnet 4
mode: agent
tools: ['codebase', 'usages', 'vscodeAPI', 'think', 'problems', 'changes', 'testFailure', 'terminalSelection', 'terminalLastCommand', 'openSimpleBrowser', 'fetch', 'findTestFiles', 'searchResults', 'githubRepo', 'extensions', 'editFiles', 'runNotebooks', 'search', 'new', 'runCommands', 'runTasks']
---


<!-- doc/prompt/prompt_summer_1.md -->

# 项目背景
架构相关内容请动态读取以下目录中的所有文件，根据架构来分析后面开发业务
- `doc/framework/`

# 基础规则
基础要求请动态读取以下目录中所有以 "base" 开头的文件：
- `doc/prompt/base_*.md` - 所有基础开发规范和要求

# 业务功能开发
业务逻辑相关内容请动态读取以下目录：
- `doc/business/` - 核心业务逻辑和规则
- `doc/features/` - 具体功能需求和实现指南

## 当前开发任务识别
AI 通过以下方式识别当前要实现的任务：

### 优先级顺序：
1. **直接对话需求**：用户在对话中明确提出的开发需求（最高优先级）
2. **任务文件**：`doc/task/current-task.md` 中指定的当前开发重点
3. **上下文推断**：基于对话历史和项目状态推断

# Agent 行为说明
- 本 chat mode 仅用于 agent 模式。
- AI 必须以 agent 工作流自动分步、批量、跨文件处理需求。
- 所有输出需动态读取上述目录中的文件内容。