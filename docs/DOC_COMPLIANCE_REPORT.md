# 文档规范符合度检查报告

## 🔍 检查结果

### ❌ 不符合规范的部分

#### 1. 使用了 `doc` 目录（单数形式）

**规范要求**：统一使用 `docs`（复数形式）

**发现的问题**：
- ❌ 根目录：`doc/` 存在（应该全部内容迁移到 `docs/`）
- ❌ kiki_server：`kiki_server/doc/` 存在
- ❌ kiki_web：`kiki_web/doc/` 存在

#### 2. API 文档位置混乱

**规范要求**：API 接口文档统一放在 `docs/api/endpoints/`

**发现的问题**：
- ❌ `doc/api/` 下有旧的 API 文档（已部分迁移但原文件未删除）
- ❌ `kiki_server/doc/api/` 有后端 API 文档（应该是实现说明，不应该放在 api/ 下）
- ❌ `kiki_web/doc/api/` 有前端 API 文档（前端不应该定义 API）

#### 3. 文档分类不清晰

**规范要求**：共享文档在根 `docs/`，专属文档在子项目 `docs/`

**发现的问题**：
- `doc/framework/` - 框架文档应该根据内容分类
- `doc/prompt/` - Prompt 文档应该移到 `.ai/dev-prompts/` 或其他合适位置
- `doc/business/` - 业务文档应该在 `docs/`
- `doc/deploy/` - 部署文档应该在 `docs/deployment/`

## 📋 改造计划

### 阶段 1：迁移子项目 doc/ 到 docs/

#### 任务 1.1：kiki_web/doc/ → kiki_web/docs/
```bash
git mv kiki_web/doc kiki_web/docs
```

**内容**：
- ARCHITECTURE_OPTIMIZATION.md
- COMPLETE_FLOW_ANALYSIS.md
- DATA_FLOW_REVIEW.md
- INTERNATIONALIZATION.md
- UI_REFACTOR_REPORT.md
- api/ (需检查是否应该删除或移到根 docs/api/)
- business/, card-generation/, features/, framework/ 等

#### 任务 1.2：kiki_server/doc/ → kiki_server/docs/
```bash
git mv kiki_server/doc kiki_server/docs
```

**内容**：
- DOCUMENTATION_SUMMARY.md
- QUICK_GUIDE.md
- README.md
- START_HERE.md
- api/ (检查是否是实现说明，改名为 implementation/)
- dev/, framwork/ 等

### 阶段 2：整理根目录 doc/

#### 任务 2.1：迁移 API 文档（已完成部分）
- ✅ doc/api/backend_api_documentation.md → docs/api/endpoints/auth.md（已完成）
- ✅ doc/api/chat_history.md → docs/api/endpoints/（已完成）
- ✅ doc/api/chat_huihua.md → docs/api/endpoints/（已完成）
- ⏳ 删除 doc/api/ 目录

#### 任务 2.2：迁移其他文档
```bash
doc/business/     → docs/business/
doc/deploy/       → docs/deployment/
doc/framework/    → docs/framework/（或分散到各子项目）
doc/prompt/       → .ai/dev-prompts/ 或 docs/prompts/
doc/features/     → docs/features/
```

#### 任务 2.3：删除空的 doc/ 目录
```bash
rm -rf doc/
```

### 阶段 3：更新文档引用

#### 任务 3.1：查找并更新所有引用
```bash
# 查找所有引用旧路径的文件
grep -r "doc/" --include="*.md" --include="*.dart" --include="*.rs"
```

#### 任务 3.2：更新引用路径
- 将 `doc/` 改为 `docs/`
- 将 `kiki_web/doc/` 改为 `kiki_web/docs/`
- 将 `kiki_server/doc/` 改为 `kiki_server/docs/`

## ⚠️ 注意事项

### 1. API 文档特别处理

**kiki_web/doc/api/** 和 **kiki_server/doc/api/**：
- 需要逐个检查内容
- 如果是接口定义 → 移到 `docs/api/endpoints/`
- 如果是实现说明 → 移到对应子项目的 `docs/implementation/`

### 2. Git 历史保留

使用 `git mv` 而不是 `rm` + `mkdir`，以保留文件历史：
```bash
git mv doc/business docs/business
```

### 3. 渐进式迁移

建议分批次提交，而不是一次性全部迁移：
1. 先迁移子项目（kiki_web, kiki_server）
2. 再迁移根目录
3. 最后更新引用和清理

## 📊 预估工作量

| 任务 | 文件数 | 预估时间 | 风险 |
|------|--------|----------|------|
| kiki_web/doc/ 迁移 | ~20 | 10分钟 | 低 |
| kiki_server/doc/ 迁移 | ~10 | 5分钟 | 低 |
| 根目录 doc/ 整理 | ~30 | 15分钟 | 中 |
| 更新引用路径 | 未知 | 10分钟 | 中 |
| **总计** | **~60** | **40分钟** | **中** |

## ✅ 完成标准

- [ ] 所有 `doc/` 目录已重命名为 `docs/`
- [ ] API 文档统一在 `docs/api/endpoints/`
- [ ] 子项目专属文档在各自的 `docs/`
- [ ] 所有文档引用路径已更新
- [ ] 旧的 `doc/` 目录已删除
- [ ] 项目可以正常构建和运行
- [ ] 文档链接可以正常访问

## 🎯 下一步行动

建议按以下顺序执行：
1. **先做备份**：确保有 git commit 记录
2. **迁移子项目**：kiki_web/doc/ 和 kiki_server/doc/
3. **整理根目录**：doc/ 内容分类迁移
4. **更新引用**：查找并替换所有旧路径
5. **验证测试**：确保一切正常
6. **提交代码**：分批次提交，便于回滚
