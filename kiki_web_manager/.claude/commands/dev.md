---
description: Complete development workflow from requirement to review with auto-optimization
allowed-tools: Read, Grep, Glob, Edit, Write, Bash(git:*,npm:*,ls:*)
---

# Development Workflow Command

You are guiding the user through a complete development workflow. This command orchestrates the entire process from requirement clarification to code review and learning.

## Arguments

- `$ARGUMENTS` - Feature description (e.g., "添加搜索功能", "优先级功能")

## Workflow Overview

```
需求澄清 → 架构设计 → UI设计 → 代码实现 → 代码审查 → 自动学习
    ↓          ↓         ↓         ↓          ↓          ↓
  SKILL     SKILL     SKILL     SKILL      SKILL      AGENT
```

## Phase Detection & Smart Resume

Before starting, detect the current stage by checking for existing artifacts:

```bash
# Check what's already done
FEATURE_SLUG=$(echo "$ARGUMENTS" | sed 's/[^a-zA-Z0-9]/-/g' | tr '[:upper:]' '[:lower:]')

if [ -f "docs/requirements/$FEATURE_SLUG.md" ]; then
  echo "✓ Requirement exists"
fi

if [ -f "docs/architecture/$FEATURE_SLUG.md" ]; then
  echo "✓ Architecture exists"
fi

if [ -f "docs/design/$FEATURE_SLUG.md" ]; then
  echo "✓ UI Design exists"
fi
```

Based on what exists:
- **Nothing exists** → Start from requirement clarification
- **Has requirement** → Offer to skip to architecture
- **Has architecture** → Offer to skip to implementation
- **Code already modified** → Jump directly to review

## Phase 1: Requirement Clarification

**Auto-activate skill**: `requirement-clarification`

### Your Process

1. **Announce phase**:
   ```
   📋 Phase 1/5: Requirement Clarification

   I'll ask you 3 core questions to clarify the requirements.
   ```

2. **Use the skill's templates**:
   - Check if `.claude/skills/requirement-clarification/` has a prompt template for this feature type
   - Common types: priority-feature, search-feature, form-feature
   - If template exists, use it; otherwise, use generic questions

3. **Ask 3 core questions**:
   - Question 1: Data structure / Core functionality
   - Question 2: UI/UX design
   - Question 3: Scope / Boundaries / Edge cases

4. **Generate requirement document**:

   Create `docs/requirements/$FEATURE_SLUG.md`:

   ```markdown
   # [$FEATURE] Requirement Document

   **Date**: YYYY-MM-DD
   **Status**: Draft

   ## 1. Task Overview

   ### Key Goals
   - Goal 1
   - Goal 2
   - Goal 3

   ### Background
   [Why this feature is needed]

   ### Scope
   - **In Scope**: What will be done
   - **Out of Scope**: What won't be done

   ## 2. Context & Assumptions

   ### Data Structure
   ```typescript
   // Example data model
   interface Task {
     id: string;
     priority: 'high' | 'medium' | 'low';
   }
   ```

   ### UI/UX Description
   - Where: [位置]
   - How: [交互方式]
   - Visual: [视觉呈现]

   ### Functional Requirements
   - [ ] Requirement 1
   - [ ] Requirement 2

   ### Edge Cases & Constraints
   - Edge case 1: [处理方式]
   - Edge case 2: [处理方式]

   ## 3. Requirement Clarity Assessment

   - Data Structure: [明确 100% | 部分明确 60% | 不明确 20%]
   - UI Design: [明确 100% | 部分明确 60% | 不明确 20%]
   - Functional Scope: [明确 100% | 部分明确 60% | 不明确 20%]
   - Edge Cases: [明确 100% | 部分明确 60% | 不明确 20%]

   **Overall Clarity**: XX%

   ## 4. Next Steps

   - [ ] Architecture design
   - [ ] UI design
   - [ ] Implementation
   ```

5. **Evaluate clarity**:
   - Calculate overall clarity percentage
   - If < 80%, suggest clarifying more
   - If ≥ 80%, proceed to next phase

6. **Ask user**:
   ```
   ✅ Requirement document generated: docs/requirements/$FEATURE_SLUG.md
   📊 Clarity score: XX%

   Ready to proceed to architecture design? (yes/no/pause)
   ```

## Phase 2: Architecture Design

**Auto-activate skill**: `architecture-design`

### Your Process

1. **Announce phase**:
   ```
   🏗️ Phase 2/5: Architecture Design

   I'll design the technical architecture based on requirements.
   ```

2. **Read requirement doc**:
   ```bash
   cat docs/requirements/$FEATURE_SLUG.md
   ```

3. **Design architecture**:
   - Data models (types, interfaces)
   - API design (if needed)
   - State management approach
   - Component structure
   - File organization

4. **Generate architecture document**:

   Create `docs/architecture/$FEATURE_SLUG.md`:

   ```markdown
   # [$FEATURE] Architecture Design

   **Date**: YYYY-MM-DD
   **Based on**: docs/requirements/$FEATURE_SLUG.md

   ## 1. Data Model

   ```typescript
   // Type definitions
   interface Priority {
     level: 'high' | 'medium' | 'low';
     color: string;
     icon?: string;
   }

   interface Task {
     id: string;
     title: string;
     priority: Priority['level'];
   }
   ```

   ## 2. State Management

   **Approach**: [Zustand / Context / Redux / Local State]

   ```typescript
   // Store structure
   interface TaskStore {
     tasks: Task[];
     setPriority: (id: string, priority: Priority['level']) => void;
   }
   ```

   ## 3. API Design (if needed)

   ```typescript
   // API endpoints
   PUT /api/tasks/:id/priority
   Body: { priority: 'high' | 'medium' | 'low' }
   ```

   ## 4. Component Structure

   ```
   src/
   ├── components/
   │   └── TaskList/
   │       ├── TaskList.tsx
   │       ├── TaskItem.tsx
   │       └── PriorityIndicator.tsx
   ├── stores/
   │   └── taskStore.ts
   └── types/
       └── task.ts
   ```

   ## 5. File Changes

   **New files**:
   - [ ] src/types/priority.ts
   - [ ] src/components/PriorityIndicator.tsx

   **Modified files**:
   - [ ] src/components/TaskItem.tsx
   - [ ] src/stores/taskStore.ts

   ## 6. Dependencies

   **New dependencies**: None
   **Existing dependencies**: [List]

   ## 7. Migration Strategy (if needed)

   - Existing data handling
   - Backward compatibility
   ```

5. **Ask user**:
   ```
   ✅ Architecture document generated: docs/architecture/$FEATURE_SLUG.md

   Ready to proceed to UI design? (yes/no/skip-to-implementation)
   ```

## Phase 3: UI Design

**Auto-activate skill**: `ui-design-system`

### Your Process

1. **Announce phase**:
   ```
   🎨 Phase 3/5: UI Design

   I'll design the UI components and interactions.
   ```

2. **Read previous docs**:
   ```bash
   cat docs/requirements/$FEATURE_SLUG.md
   cat docs/architecture/$FEATURE_SLUG.md
   ```

3. **Design UI**:
   - Component layout
   - Color scheme (use design tokens if available)
   - Interaction states (hover, active, disabled)
   - Animations (if needed)
   - Responsive behavior

4. **Generate UI design document**:

   Create `docs/design/$FEATURE_SLUG.md`:

   ```markdown
   # [$FEATURE] UI Design

   **Date**: YYYY-MM-DD
   **Based on**: Architecture design

   ## 1. Component: PriorityIndicator

   ### Visual Design

   ```
   High Priority:    ● (Red circle, #FF3B30)
   Medium Priority:  ● (Yellow circle, #FFCC00)
   Low Priority:     ● (Gray circle, #8E8E93)
   ```

   ### States

   - **Default**: Show current priority color
   - **Hover**: Scale 110%, show tooltip
   - **Active**: Show priority selector dropdown
   - **Disabled**: Opacity 50%

   ### Interactions

   1. Click indicator → Show priority dropdown
   2. Select priority → Update immediately + Close dropdown
   3. Click outside → Close dropdown

   ## 2. Layout

   ```
   ┌─────────────────────────────────┐
   │ TaskItem                        │
   │ ┌───┐ Task Title          [⋮]  │
   │ │ ● │ Description              │
   │ └───┘                           │
   └─────────────────────────────────┘
      ↑
   Priority Indicator
   ```

   ## 3. Design Tokens

   ```typescript
   const PRIORITY_CONFIG = {
     high: { color: '#FF3B30', label: '高' },
     medium: { color: '#FFCC00', label: '中' },
     low: { color: '#8E8E93', label: '低' }
   };
   ```

   ## 4. Accessibility

   - [ ] Color is not the only indicator (use icons too)
   - [ ] Keyboard navigation support (Tab, Enter, Escape)
   - [ ] ARIA labels for screen readers
   - [ ] Focus visible indicator
   ```

5. **Ask user**:
   ```
   ✅ UI design document generated: docs/design/$FEATURE_SLUG.md

   Ready to proceed to implementation? (yes/no/pause)
   ```

## Phase 4: Code Implementation

**Auto-activate skill**: `code-implementation`

### Your Process

1. **Announce phase**:
   ```
   💻 Phase 4/5: Code Implementation

   I'll implement the code following the architecture and design.
   ```

2. **Read all previous docs**:
   ```bash
   cat docs/requirements/$FEATURE_SLUG.md
   cat docs/architecture/$FEATURE_SLUG.md
   cat docs/design/$FEATURE_SLUG.md
   ```

3. **Implement following the skill's best practices**:
   - Follow file organization patterns
   - Use naming conventions
   - Implement error handling
   - Add TypeScript types
   - Follow code quality checklist

4. **As you implement**:
   - Create new files as designed
   - Modify existing files
   - Follow the architecture exactly
   - Use design tokens from UI design

5. **After implementation**:
   ```
   ✅ Implementation complete

   Files changed:
   - Created: src/types/priority.ts
   - Created: src/components/PriorityIndicator.tsx
   - Modified: src/components/TaskItem.tsx
   - Modified: src/stores/taskStore.ts

   🔍 Auto-triggering code review...
   ```

## Phase 5: Code Review (Auto-triggered)

**Auto-activate skill**: `code-review`

**Note**: This phase should be auto-triggered by PostToolUse hook after Edit/Write. If hook is not configured yet, trigger manually.

### Your Process

1. **Announce phase**:
   ```
   🔍 Phase 5/5: Code Review

   Running comprehensive code quality check...
   ```

2. **Run the 15-point checklist** from `code-review` skill:
   - Completeness
   - Correctness
   - Testability
   - Reusability
   - Consistency
   - Design
   - Error Handling
   - Security
   - Documentation
   - Performance
   - UX
   - Data Migration
   - Dependencies
   - Git
   - Compliance

3. **Generate review report**:

   Create `docs/reviews/YYYY-MM-DD-$FEATURE_SLUG.md`:

   ```markdown
   # Code Review: [$FEATURE]

   **Date**: YYYY-MM-DD
   **Reviewer**: Claude Code Review Skill
   **Score**: XX/15 (XX%)

   ## ✅ Passed (XX items)

   1. ✅ All features implemented
   2. ✅ Naming conventions followed
   3. ✅ TypeScript types defined
   ...

   ## ⚠️ Critical - Must Fix

   ### 1. Missing Error Handling
   **Location**: `src/stores/taskStore.ts:45`
   **Issue**: API call lacks try-catch
   **Fix**:
   ```typescript
   try {
     await api.updatePriority(id, priority);
   } catch (error) {
     console.error(error);
     showError('更新失败');
   }
   ```

   ## ⚠️ Warning - Should Fix

   ### 1. Repeated Code
   **Location**: `TaskItem.tsx:20` and `PriorityIndicator.tsx:15`
   **Issue**: Same color mapping logic
   **Fix**: Extract to `utils/priority.ts`

   ## 💡 Suggestions

   ### 1. Performance Optimization
   **Location**: `TaskList.tsx:50`
   **Suggestion**: Use useMemo to cache filtered list

   ## Overall Assessment

   - **Quality**: Good (73%)
   - **Recommendation**: Fix critical issues, then ready to commit
   - **Next improvement**: Add error handling checklist to requirement phase
   ```

4. **Show summary**:
   ```
   ✅ Code Review Complete

   Score: 11/15 (73% - Good)

   Critical issues: 1
   Warnings: 1
   Suggestions: 1

   📄 Full report: docs/reviews/YYYY-MM-DD-$FEATURE_SLUG.md

   🤖 Auto-triggering skill learning agent...
   ```

## Phase 6: Auto Learning (Auto-triggered)

**Trigger agent**: `skill-learner`

**Note**: This should happen automatically after review.

### What Happens

The `skill-learner` agent will:
1. Read the review report
2. Detect recurring patterns (e.g., "missing error handling" 3rd time)
3. Auto-update relevant skills
4. Save learning case
5. Report optimization results

## User Controls

Allow user to control the workflow:

### Skip Stages
```
User: /dev 添加搜索 --skip-design
→ Skip UI design phase, jump from architecture to implementation
```

### Jump to Stage
```
User: /dev 添加搜索 --review-only
→ Only run code review on existing code
```

### Pause Workflow
```
User: pause
→ Stop and wait for user
```

### Resume Workflow
```
User: continue
→ Resume from last stage
```

## State Tracking

Create/Update `.claude/workflow-state.json`:

```json
{
  "feature": "$FEATURE_NAME",
  "featureSlug": "$FEATURE_SLUG",
  "currentStage": "implementation",
  "completedStages": ["requirement", "architecture", "design"],
  "artifacts": {
    "requirement": "docs/requirements/$FEATURE_SLUG.md",
    "architecture": "docs/architecture/$FEATURE_SLUG.md",
    "design": "docs/design/$FEATURE_SLUG.md",
    "review": "docs/reviews/YYYY-MM-DD-$FEATURE_SLUG.md"
  },
  "startedAt": "2026-01-10T10:00:00Z",
  "updatedAt": "2026-01-10T10:30:00Z"
}
```

## Error Handling

If anything goes wrong:
1. Save current state to workflow-state.json
2. Explain what happened
3. Suggest how to resume
4. Don't lose user's answers or progress

## Best Practices

1. **Always ask before proceeding** - Don't auto-continue to next phase
2. **Save artifacts incrementally** - Don't wait until the end
3. **Show progress clearly** - Use phase indicators
4. **Allow flexibility** - User can skip/pause/jump
5. **Preserve context** - Read previous docs before each phase

## Example Usage

```
User: /dev 添加搜索功能

Claude:
📋 Phase 1/5: Requirement Clarification

I'll ask you 3 core questions about the search feature.

### Question 1: Search Scope
What fields should be searchable?
Options:
- Title only
- Title + Content
- Title + Content + Tags
- All fields

User: Title + Content

Claude:
### Question 2: Search Method
How should search work?
Options:
- Real-time (search as you type)
- Button trigger (click search button)
- Keyboard shortcut (Ctrl+F)

User: Real-time

Claude:
### Question 3: Advanced Features
Do you need any of these?
- [ ] Search history
- [ ] Advanced filters (date, status)
- [ ] Search suggestions
- [ ] Save searches

User: Just search history

Claude:
✅ Requirement document generated: docs/requirements/search.md
📊 Clarity score: 85%

Ready to proceed to architecture design? (yes/no/pause)

[... workflow continues ...]
```

## Integration with Skills

This command orchestrates skills, it doesn't replace them:

- **requirement-clarification** - Provides question templates and standards
- **architecture-design** - Provides design patterns
- **ui-design-system** - Provides UI components and tokens
- **code-implementation** - Provides coding standards
- **code-review** - Provides review checklist

The command's job is to **guide the flow** and **ensure all phases happen in order**.
