<template>
  <div class="dashboard-container">
    <el-row :gutter="20">
      <el-col :span="6">
        <el-card shadow="hover">
          <el-statistic title="总用户数" :value="stats.totalUsers">
            <template #prefix>
              <el-icon color="#409EFF"><User /></el-icon>
            </template>
          </el-statistic>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <el-statistic title="场景分类" :value="stats.totalCategories">
            <template #prefix>
              <el-icon color="#67C23A"><Grid /></el-icon>
            </template>
          </el-statistic>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <el-statistic title="场景总数" :value="stats.totalScenes">
            <template #prefix>
              <el-icon color="#E6A23C"><Picture /></el-icon>
            </template>
          </el-statistic>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <el-statistic title="物品总数" :value="stats.totalItems">
            <template #prefix>
              <el-icon color="#F56C6C"><Box /></el-icon>
            </template>
          </el-statistic>
        </el-card>
      </el-col>
    </el-row>
    
    <el-row :gutter="20" style="margin-top: 20px">
      <el-col :span="12">
        <el-card>
          <template #header>
            <span>最近创建的场景</span>
          </template>
          <el-table :data="recentScenes" v-loading="loading">
            <el-table-column prop="name" label="名称" />
            <el-table-column prop="item_count" label="物品数" width="100" align="center" />
            <el-table-column prop="created_at" label="创建时间" width="180">
              <template #default="{ row }">
                {{ formatDate(row.created_at) }}
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
      
      <el-col :span="12">
        <el-card>
          <template #header>
            <span>最近注册用户</span>
          </template>
          <el-table :data="recentUsers" v-loading="loading">
            <el-table-column prop="name" label="昵称" />
            <el-table-column prop="phone" label="手机号" width="150" />
            <el-table-column prop="created_at" label="注册时间" width="180">
              <template #default="{ row }">
                {{ formatDate(row.created_at) }}
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { categoryAPI } from '../api/categories'
import { sceneAPI } from '../api/scenes'
import { userAPI } from '../api/users'

const loading = ref(false)

const stats = reactive({
  totalUsers: 0,
  totalCategories: 0,
  totalScenes: 0,
  totalItems: 0
})

const recentScenes = ref<any[]>([])
const recentUsers = ref<any[]>([])

const fetchStats = async () => {
  loading.value = true
  try {
    const [categoriesRes, scenesRes, usersRes] = await Promise.all([
      categoryAPI.list(),
      sceneAPI.list(),
      userAPI.list()
    ])
    
    const scenes = scenesRes.data?.scenes ?? scenesRes.data ?? []
    stats.totalCategories = categoriesRes.data.length
    stats.totalScenes = scenes.length
    stats.totalUsers = usersRes.data.length
    stats.totalItems = scenes.reduce((sum: number, scene: any) => sum + (scene.item_count ?? 0), 0)

    recentScenes.value = [...scenes]
      .sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime())
      .slice(0, 5)
    
    recentUsers.value = usersRes.data
      .sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime())
      .slice(0, 5)
  } catch (error) {
    console.error('Failed to fetch stats:', error)
  } finally {
    loading.value = false
  }
}

const formatDate = (dateStr: string) => {
  return new Date(dateStr).toLocaleString('zh-CN')
}

onMounted(() => {
  fetchStats()
})
</script>

<style scoped>
.dashboard-container {
  padding: 20px;
}
</style>
