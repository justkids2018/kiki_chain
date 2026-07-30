<template>
  <el-container class="layout-container kiki-admin">
    <el-aside :width="isCollapsed ? '72px' : '216px'">
      <div class="brand" :class="{ compact: isCollapsed }">
        <div class="brand-mark">K</div>
        <div v-show="!isCollapsed" class="brand-copy">
          <strong>Hi Kiki</strong>
          <span>管理后台</span>
        </div>
      </div>
      <el-menu
        :default-active="activeMenu"
        router
        :collapse="isCollapsed"
        :collapse-transition="false"
      >
        <el-menu-item index="/dashboard">
          <el-icon><DataAnalysis /></el-icon>
          <span>数据总览</span>
        </el-menu-item>
        <el-menu-item index="/categories">
          <el-icon><Grid /></el-icon>
          <span>主题管理</span>
        </el-menu-item>
        <el-menu-item index="/scenes">
          <el-icon><Picture /></el-icon>
          <span>学习卡片</span>
        </el-menu-item>
        <el-menu-item index="/users">
          <el-icon><User /></el-icon>
          <span>用户管理</span>
        </el-menu-item>
        <el-menu-item index="/feedback">
          <el-icon><ChatDotRound /></el-icon>
          <span>帮助与反馈</span>
        </el-menu-item>
      </el-menu>
    </el-aside>
    
    <el-container>
      <el-header height="64px">
        <div class="header-content">
          <div class="header-leading">
            <el-button
              class="collapse-button"
              circle
              text
              :aria-label="isCollapsed ? '展开侧边栏' : '收起侧边栏'"
              @click="isCollapsed = !isCollapsed"
            >
              <el-icon><Expand v-if="isCollapsed" /><Fold v-else /></el-icon>
            </el-button>
            <div>
              <span class="eyebrow">KIKI ADMIN</span>
              <h1 class="title">{{ currentTitle }}</h1>
            </div>
          </div>
          <el-dropdown @command="handleCommand">
            <span class="user-info">
              <span class="user-avatar">{{ userName.slice(0, 1).toUpperCase() }}</span>
              <span>{{ userName }}</span>
              <el-icon><ArrowDown /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="logout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>
      
      <el-main id="main-content">
        <router-view v-slot="{ Component, route: currentRoute }">
          <keep-alive>
            <component :is="Component" :key="currentRoute.fullPath" />
          </keep-alive>
        </router-view>
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { authAPI } from '../api/auth'

const router = useRouter()
const route = useRoute()

const userName = ref(JSON.parse(localStorage.getItem('admin_user') || '{}').name || 'Admin')
const isCollapsed = ref(false)

const activeMenu = computed(() => route.path)
const currentTitle = computed(() => route.meta.title as string || '')

const handleCommand = async (command: string) => {
  if (command === 'logout') {
    try {
      await ElMessageBox.confirm('确定要退出登录吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      })
      
      await authAPI.logout()
      localStorage.removeItem('admin_token')
      localStorage.removeItem('admin_user')
      
      ElMessage.success('已退出登录')
      router.push('/login')
    } catch (error) {
      // User cancelled
    }
  }
}
</script>

<style scoped>
.layout-container {
  background: var(--kiki-color-canvas);
  min-height: calc(100vh - 40px);
}

.el-aside {
  overflow: hidden;
  background: var(--kiki-color-sidebar);
  border-right: 1px solid var(--kiki-color-border);
  transition: width var(--kiki-motion-fast);
}

.brand {
  height: 72px;
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 0 16px;
  border-bottom: 1px solid var(--kiki-color-border);
}

.brand.compact { justify-content: center; padding: 0; }
.brand-mark, .user-avatar {
  display: grid;
  place-items: center;
  flex: 0 0 auto;
  border-radius: 50%;
  color: white;
  background: var(--kiki-color-brand);
}
.brand-mark { width: 40px; height: 40px; font-weight: 800; }
.brand-copy { display: flex; flex-direction: column; line-height: 1.25; white-space: nowrap; }
.brand-copy strong { font-size: 15px; }
.brand-copy span, .eyebrow { color: var(--kiki-color-text-muted); font-size: 11px; }

.el-menu {
  padding: 12px 8px;
  border-right: 0;
  background: transparent;
}
:deep(.el-menu-item) { height: 48px; margin-bottom: 4px; border-radius: var(--kiki-radius-sm); }
:deep(.el-menu-item.is-active) { color: var(--kiki-color-brand); background: var(--kiki-color-brand-soft); }
:deep(.el-menu--collapse .el-menu-item) { justify-content: center; padding: 0; }
:deep(.el-menu--collapse .el-menu-item .el-icon) { margin: 0; }

.el-container { min-width: 0; }
.el-header {
  display: flex;
  align-items: center;
  padding: 0 24px;
  background: var(--kiki-color-surface);
  border-bottom: 1px solid var(--kiki-color-border);
}

.header-content, .header-leading, .user-info {
  display: flex;
  align-items: center;
}
.header-content { width: 100%; justify-content: space-between; }
.header-leading { gap: 12px; }
.collapse-button { width: 40px; }
.eyebrow { display: block; letter-spacing: 0.12em; }
.title { margin: 1px 0 0; font-size: 20px; line-height: 1.2; letter-spacing: -0.012em; }
.user-info { gap: 8px; cursor: pointer; color: var(--kiki-color-text-secondary); }
.user-avatar { width: 32px; height: 32px; font-size: 13px; font-weight: 700; }
.el-main { overflow-x: hidden; padding: 24px; background: var(--kiki-color-canvas); }

@media (max-width: 900px) {
  .el-main { padding: 16px; }
  .user-info > span:nth-child(2) { display: none; }
}
</style>
