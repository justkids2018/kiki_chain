<template>
  <div class="login-container">
    <el-card class="login-card">
      <h2>Hi Kiki 管理后台</h2>
      <el-form :model="form" :rules="rules" ref="formRef" @submit.prevent="handleLogin">
        <el-form-item prop="identifier">
          <el-input
            v-model="form.identifier"
            placeholder="手机号"
            prefix-icon="User"
            size="large"
          />
        </el-form-item>
        <el-form-item prop="password">
          <el-input
            v-model="form.password"
            placeholder="密码"
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
    </el-card>
  </div>
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
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.login-card {
  width: 400px;
  padding: 20px;
}

h2 {
  text-align: center;
  margin-bottom: 30px;
  color: #333;
}
</style>
