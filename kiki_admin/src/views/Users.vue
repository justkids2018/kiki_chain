<template>
  <div class="users-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>用户管理</span>
          <el-input
            v-model="searchText"
            placeholder="搜索手机号或昵称"
            style="width: 300px"
            clearable
            @input="handleSearch"
          >
            <template #prefix>
              <el-icon><Search /></el-icon>
            </template>
          </el-input>
        </div>
      </template>

      <el-table :data="filteredUsers" v-loading="loading" border>
        <el-table-column prop="uid" label="用户 ID" width="150" />
        <el-table-column prop="name" label="昵称" width="150" />
        <el-table-column prop="phone" label="手机号" width="150" />
        <el-table-column prop="role_type" label="角色" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="row.role_type === 2 ? 'danger' : 'primary'" size="small">
              {{ row.role_type === 2 ? '管理员' : '普通用户' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="is_vip" label="VIP" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="row.is_vip ? 'warning' : 'info'" size="small">
              {{ row.is_vip ? '是' : '否' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="created_at" label="注册时间" width="180">
          <template #default="{ row }">
            {{ formatDate(row.created_at) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" align="center" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleView(row)">详情</el-button>
            <el-button type="warning" size="small" @click="handleEdit(row)">编辑</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 用户详情对话框 -->
    <el-dialog
      v-model="dialogVisible"
      title="用户详情"
      width="600px"
    >
      <el-descriptions :column="2" border v-if="currentUser">
        <el-descriptions-item label="用户 ID">{{ currentUser.uid }}</el-descriptions-item>
        <el-descriptions-item label="昵称">{{ currentUser.name }}</el-descriptions-item>
        <el-descriptions-item label="手机号">{{ currentUser.phone }}</el-descriptions-item>
        <el-descriptions-item label="角色">
          <el-tag :type="currentUser.role_type === 2 ? 'danger' : 'primary'" size="small">
            {{ currentUser.role_type === 2 ? '管理员' : '普通用户' }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="VIP">
          <el-tag :type="currentUser.is_vip ? 'warning' : 'info'" size="small">
            {{ currentUser.is_vip ? '是' : '否' }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="注册时间" :span="2">
          {{ formatDate(currentUser.created_at) }}
        </el-descriptions-item>
      </el-descriptions>
    </el-dialog>

    <!-- 编辑用户对话框 -->
    <el-dialog
      v-model="editDialogVisible"
      title="编辑用户"
      width="600px"
    >
      <el-form :model="editForm" :rules="editRules" ref="editFormRef" label-width="100px">
        <el-form-item label="用户 ID">
          <el-input v-model="editForm.uid" disabled />
        </el-form-item>
        <el-form-item label="昵称" prop="name">
          <el-input v-model="editForm.name" placeholder="请输入昵称" />
        </el-form-item>
        <el-form-item label="密码" prop="password">
          <el-input
            v-model="editForm.password"
            type="password"
            placeholder="留空则不修改密码"
            show-password
          />
        </el-form-item>
        <el-form-item label="VIP 状态">
          <el-switch v-model="editForm.is_vip" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="editDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleUpdate" :loading="updating">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { userAPI, type User } from '../api/users'

const loading = ref(false)
const updating = ref(false)
const users = ref<User[]>([])
const searchText = ref('')
const dialogVisible = ref(false)
const editDialogVisible = ref(false)
const currentUser = ref<User | null>(null)
const editFormRef = ref()

const editForm = ref({
  uid: '',
  name: '',
  password: '',
  is_vip: false
})

const editRules = {
  name: [
    { required: true, message: '请输入昵称', trigger: 'blur' },
    { min: 2, max: 50, message: '昵称长度在 2 到 50 个字符', trigger: 'blur' }
  ],
  password: [
    { min: 6, max: 20, message: '密码长度在 6 到 20 个字符', trigger: 'blur' }
  ]
}

const filteredUsers = computed(() => {
  if (!searchText.value) return users.value

  const search = searchText.value.toLowerCase()
  return users.value.filter(user =>
    user.name.toLowerCase().includes(search) ||
    user.phone.includes(search) ||
    user.uid.toLowerCase().includes(search)
  )
})

const fetchUsers = async () => {
  loading.value = true
  try {
    const res = await userAPI.list()
    users.value = res.data
  } catch (error) {
    console.error('Failed to fetch users:', error)
    ElMessage.error('获取用户列表失败')
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  // Computed property will handle filtering
}

const handleView = (row: User) => {
  currentUser.value = row
  dialogVisible.value = true
}

const handleEdit = (row: User) => {
  editForm.value = {
    uid: row.uid,
    name: row.name,
    password: '',
    is_vip: row.is_vip
  }
  editDialogVisible.value = true
}

const handleUpdate = async () => {
  if (!editFormRef.value) return

  await editFormRef.value.validate(async (valid: boolean) => {
    if (!valid) return

    updating.value = true
    try {
      const updateData: any = {
        name: editForm.value.name,
        is_vip: editForm.value.is_vip
      }

      // 只有填写了密码才更新密码
      if (editForm.value.password) {
        updateData.password = editForm.value.password
      }

      await userAPI.update(editForm.value.uid, updateData)
      ElMessage.success('更新成功')
      editDialogVisible.value = false

      // 刷新列表
      await fetchUsers()
    } catch (error: any) {
      console.error('Failed to update user:', error)
      ElMessage.error(error.response?.data?.message || '更新失败')
    } finally {
      updating.value = false
    }
  })
}

const formatDate = (dateStr: string) => {
  return new Date(dateStr).toLocaleString('zh-CN')
}

onMounted(() => {
  fetchUsers()
})
</script>

<style scoped>
.users-container {
  height: 100%;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
