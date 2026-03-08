# 用户收藏场景功能

**优先级**: P1
**状态**: 📝 待办
**涉及端**: 后端 + 移动端
**预计时间**: 4 小时
**创建时间**: 2026-03-04
**创建者**: Product Team

---

## 📝 需求描述

### 背景
用户在浏览场景时，希望能够收藏喜欢的场景，方便后续快速访问和学习。

### 目标
实现用户收藏功能，包括添加收藏、取消收藏、查看收藏列表等功能。

### 范围
包含:
- 用户可以收藏/取消收藏场景
- 用户可以查看自己的收藏列表
- 移动端场景详情页显示收藏按钮
- 移动端新增"我的收藏"页面

不包含:
- 收藏分类功能
- 收藏导出功能
- 收藏分享功能

---

## 🎯 技术方案

### 后端
- [ ] 数据模型设计
  - 表名: `user_favorites`
  - 字段:
    - id: BIGSERIAL PRIMARY KEY
    - user_id: BIGINT NOT NULL (外键 → users.id)
    - scene_id: BIGINT NOT NULL (外键 → scenes.id)
    - created_at: TIMESTAMP
    - 唯一约束: (user_id, scene_id)

- [ ] API 设计
  - `POST /api/v1/mobile/favorites` - 添加收藏
    - Body: `{ scene_id: number }`
    - Response: `{ id, user_id, scene_id, created_at }`

  - `DELETE /api/v1/mobile/favorites/{id}` - 取消收藏
    - Response: `{ success: true }`

  - `GET /api/v1/mobile/users/{user_id}/favorites` - 获取收藏列表
    - Query: `page`, `size`
    - Response: `Scene[]` (关联查询 scenes 表)

  - `GET /api/v1/mobile/favorites/check?scene_id={id}` - 检查是否已收藏
    - Response: `{ is_favorited: boolean, favorite_id: number? }`

- [ ] 业务逻辑
  - 用户只能收藏自己的内容（权限验证）
  - 防止重复收藏（唯一约束）
  - 收藏数量限制（最多 100 个，可配置）
  - 软删除支持（如果需要）

### 移动端
- [ ] UI 设计
  - 场景详情页: 添加收藏/取消收藏按钮（右上角心形图标）
  - 我的收藏页面: 显示收藏的场景列表（类似场景列表页）

- [ ] 功能实现
  - `FavoriteButton` 组件（可复用）
  - `MyFavoritesPage` 页面
  - `FavoriteController` 状态管理
  - 收藏状态实时更新
  - 乐观更新 UI（先更新UI，再调用API）

---

## 🔗 依赖关系

### 前置依赖
- 依赖: 用户认证功能 (已完成)
- 依赖: 场景管理功能 (已完成)

### 后续任务
无

---

## 🤖 自动化执行

是否允许自动执行？ [x] 是

执行策略：
- [x] 自动生成契约
- [x] 自动生成代码框架
- [ ] 自动补充业务逻辑（需人工补充：权限验证、数量限制）
- [x] 自动生成测试
- [x] 自动代码审查

执行 Skills:
1. /contract-manager - 创建 user_favorite.contract.yaml
2. /code-generator - 生成三端代码
3. kiki_server/code-implementation - 后端实现（补充业务逻辑 20%）
4. kiki_web/code-implementation - 移动端实现（UI + 交互）
5. kiki_server/code-review - 后端代码审查
6. kiki_web/code-review - 移动端代码审查

---

## ✅ 验收标准

### 功能验收
- [ ] 用户可以添加收藏（点击心形按钮）
- [ ] 用户可以取消收藏（再次点击心形按钮）
- [ ] 收藏按钮状态正确显示（已收藏/未收藏）
- [ ] 我的收藏页面正确显示收藏列表
- [ ] 收藏列表支持分页加载
- [ ] 防止重复收藏
- [ ] 收藏数量限制生效（最多 100 个）

### 边界情况
- [ ] 未登录用户点击收藏，提示需要登录
- [ ] 收藏数量达到上限，提示用户
- [ ] 网络错误时，给出友好提示
- [ ] 场景被删除后，收藏列表不显示该场景

### 代码质量
- [ ] 后端代码编译通过
- [ ] 前端代码编译通过
- [ ] 单元测试通过（覆盖率 > 80%）
- [ ] API 集成测试通过
- [ ] 代码审查通过

### 文档
- [ ] API 文档更新
- [ ] 契约文件创建
- [ ] 代码注释完整

---

## 📊 执行记录

<!-- 任务执行后由 task-executor 自动填写 -->

---

## 🔗 相关链接

- 契约文件: `.claude/contracts/user_favorite.contract.yaml` (待创建)
- 相关文档: `docs/features/收藏功能.md` (待创建)
- 设计稿: [Figma 链接]

---

**示例版本**: v1.0
**最后更新**: 2026-03-04
