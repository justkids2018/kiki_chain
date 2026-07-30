<template>
  <main class="login-page kiki-admin">
    <section class="brand-panel" aria-label="Kiki 管理后台介绍">
      <div class="brand-lockup">
        <span class="brand-mark">K</span>
        <div>
          <strong>Hi Kiki</strong>
          <span>管理后台</span>
        </div>
      </div>
      <div class="brand-message">
        <span class="eyebrow">KIKI ADMIN</span>
        <h1>让每一次运营管理<br />都清晰而从容</h1>
        <p>集中管理学习内容、用户与反馈，让团队专注于创造更好的学习体验。</p>
      </div>
      <span class="brand-note">Kiki learning operations</span>
    </section>

    <section class="login-panel">
      <div class="login-card">
      <header>
        <span class="mobile-mark">K</span>
        <span class="section-kicker">WELCOME BACK</span>
        <h2>登录管理后台</h2>
        <p>使用管理员账号继续</p>
      </header>
      <el-form :model="form" :rules="rules" ref="formRef" @submit.prevent="handleLogin">
        <label class="field-label" for="admin-identifier">管理员账号</label>
        <el-form-item prop="identifier">
          <el-input
            id="admin-identifier"
            v-model="form.identifier"
            placeholder="请输入手机号或邮箱"
            prefix-icon="User"
            size="large"
          />
        </el-form-item>
        <label class="field-label" for="admin-password">密码</label>
        <el-form-item prop="password">
          <el-input
            id="admin-password"
            v-model="form.password"
            placeholder="请输入密码"
            prefix-icon="Lock"
            type="password"
            show-password
            size="large"
            @keyup.enter="handleLogin"
          />
        </el-form-item>
        <el-form-item>
          <el-button
            type="primary"
            size="large"
            :loading="loading"
            @click="handleLogin"
            style="width: 100%"
          >
            登录
          </el-button>
        </el-form-item>
      </el-form>
      <p class="security-note"><el-icon><Lock /></el-icon> 仅限授权管理员访问</p>
      </div>
    </section>
  </main>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import { authAPI } from '../api/auth'

const router = useRouter()
const formRef = ref<FormInstance>()
const loading = ref(false)

const defaultTestCreds = {
  identifier: '',
  password: ''
}

const form = reactive({
  identifier: import.meta.env.DEV ? defaultTestCreds.identifier : '',
  password: import.meta.env.DEV ? defaultTestCreds.password : ''
})

const rules: FormRules = {
  identifier: [{ required: true, message: '请输入手机号', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

const handleLogin = async () => {
  if (!formRef.value) return
  
  await formRef.value.validate(async (valid) => {
    if (!valid) return
    
    loading.value = true
    try {
      const res = await authAPI.login(form)
      
      if (res.data.role_type !== 2) {
        ElMessage.error('无管理员权限')
        return
      }
      
      localStorage.setItem('admin_token', res.data.token)
      localStorage.setItem('admin_user', JSON.stringify(res.data))
      
      ElMessage.success('登录成功')
      router.push('/')
    } catch (error) {
      console.error('Login failed:', error)
    } finally {
      loading.value = false
    }
  })
}
</script>

<style scoped>
.login-page {
  display: grid;
  grid-template-columns: minmax(360px, 44%) 1fr;
  min-height: calc(100vh - 40px);
  background: var(--kiki-color-surface);
}

.brand-panel {
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  padding: 48px;
  color: var(--kiki-color-text);
  background: var(--kiki-color-brand-soft);
  border-right: 1px solid var(--kiki-color-border);
}

.brand-lockup, .brand-lockup > div, .security-note {
  display: flex;
  align-items: center;
}
.brand-lockup { gap: 12px; }
.brand-lockup > div { align-items: flex-start; flex-direction: column; line-height: 1.2; }
.brand-lockup strong { font-size: 16px; }
.brand-lockup > div span { color: var(--kiki-color-text-secondary); font-size: 12px; }
.brand-mark, .mobile-mark {
  display: grid;
  place-items: center;
  border-radius: 50%;
  color: white;
  background: var(--kiki-color-brand);
  font-weight: 800;
}
.brand-mark { width: 44px; height: 44px; }
.mobile-mark { display: none; width: 40px; height: 40px; margin-bottom: 20px; }
.eyebrow, .section-kicker { color: var(--kiki-color-brand); font-size: 11px; font-weight: 700; letter-spacing: .14em; }
.brand-message h1 { max-width: 560px; margin: 12px 0 20px; font-size: clamp(32px, 3.2vw, 52px); line-height: 1.12; letter-spacing: -.022em; text-wrap: balance; }
.brand-message p { max-width: 480px; margin: 0; color: var(--kiki-color-text-secondary); font-size: 15px; line-height: 1.8; text-wrap: pretty; }
.brand-note { color: var(--kiki-color-text-muted); font-size: 12px; letter-spacing: .08em; }

.login-panel { display: grid; place-items: center; padding: 48px 32px; }
.login-card { width: min(100%, 400px); }
.login-card header { margin-bottom: 32px; }
.login-card h2 { margin: 8px 0 6px; color: var(--kiki-color-text); font-size: 28px; letter-spacing: -.012em; }
.login-card header p { margin: 0; color: var(--kiki-color-text-muted); font-size: 14px; }
.field-label { display: block; margin-bottom: 8px; color: var(--kiki-color-text-secondary); font-size: 13px; font-weight: 600; }
.login-card :deep(.el-form-item) { margin-bottom: 22px; }
.login-card :deep(.el-input__wrapper) { min-height: 48px; }
.login-card :deep(.el-button) { min-height: 48px; margin-top: 4px; font-weight: 700; }
.security-note { justify-content: center; gap: 6px; margin: 22px 0 0; color: var(--kiki-color-text-muted); font-size: 12px; }

@media (max-width: 860px) {
  .login-page { grid-template-columns: 1fr; background: var(--kiki-color-canvas); }
  .brand-panel { display: none; }
  .login-panel { padding: 40px 24px; }
  .login-card { padding: 28px; border-radius: var(--kiki-radius-lg); background: var(--kiki-color-surface); box-shadow: var(--kiki-shadow-panel); }
  .mobile-mark { display: grid; }
}
</style>
