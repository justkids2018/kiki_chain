# Claude Code Configuration

This directory contains Claude Code configuration files.

## Structure

```
.claude/
├── agents/              # Specialized AI assistants
│   └── skill-learner.md # Auto-optimizes skills from review feedback
├── commands/            # Slash commands (/command-name)
│   └── dev.md          # Complete development workflow
├── hooks/               # Auto-trigger scripts
│   └── post-edit.sh    # Auto-format Kotlin code after editing
├── scripts/             # Automation scripts
│   ├── create-activity.sh  # Generate Activity template
│   └── create-fragment.sh  # Generate Fragment template
├── skills/              # Domain knowledge documents (5 skills)
│   ├── requirement-clarification/  # 需求澄清
│   ├── ui-design-analysis/         # UI 设计分析（新增）
│   ├── code-implementation/        # 代码实现（Android/Kotlin）
│   ├── code-review/                # 代码审查（15项）
│   └── bug-analysis/               # Bug 分析（Android）
└── settings.local.json  # Personal settings (gitignored)
```

## Workflow Artifacts

Workflow artifacts (requirements, architecture docs, reviews, etc.) are stored in:
- `docs/requirements/` - Requirement documents
- `docs/architecture/` - Architecture designs
- `docs/design/` - UI/UX designs
- `docs/reviews/` - Code review reports
- `docs/learnings/` - Learning cases from optimizations

## Usage

### Development Workflow
```bash
# Start complete workflow (6 phases)
/dev 添加登录功能

# Skip UI design phase
/dev 添加搜索功能 --skip-design

# Review existing code only
/dev 用户中心改造 --review-only
```

### Manual Skills & Agents
```bash
# Analyze UI design from image
"这是设计稿 [拖拽图片]，帮我生成布局"

# Clarify requirements
"帮我澄清需求：添加多页笔迹同步功能"

# Implement feature
"如何实现登录功能"

# Review code
"Review 这段代码"

# Analyze bug
"帮我分析这个崩溃 [粘贴日志]"

# Learn from reviews
"使用 skill-learner agent 分析最近的审查"
```

### Scripts
```bash
# Generate Activity
"运行脚本：create-activity LoginActivity"
# Or manually:
bash .claude/scripts/create-activity.sh LoginActivity

# Generate Fragment
"运行脚本：create-fragment HomeFragment"

# Or manually:
bash .claude/scripts/create-fragment.sh HomeFragment
```

### Hooks (Auto-triggered)
```bash
# post-edit.sh - Runs after Edit/Write tool
# Automatically formats Kotlin files with ktlint
```

See individual files for detailed documentation.
