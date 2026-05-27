<template>
  <div class="feedback-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>帮助与反馈</span>
          <el-select v-model="statusFilter" placeholder="状态筛选" style="width: 180px" @change="fetchFeedback">
            <el-option label="全部" value="" />
            <el-option label="待处理" value="pending" />
            <el-option label="处理中" value="processing" />
            <el-option label="已解决" value="resolved" />
            <el-option label="已忽略" value="ignored" />
          </el-select>
        </div>
      </template>

      <el-table :data="feedbackList" v-loading="loading" border>
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="user_id" label="用户ID" width="160" />
        <el-table-column prop="feedback_type" label="类型" width="120" />
        <el-table-column prop="content" label="反馈内容" min-width="320" show-overflow-tooltip />
        <el-table-column prop="contact" label="联系方式" width="180" />
        <el-table-column prop="page" label="来源页面" width="180" />
        <el-table-column prop="created_at" label="提交时间" width="180">
          <template #default="{ row }">
            {{ formatDate(row.created_at) }}
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="130" align="center">
          <template #default="{ row }">
            <el-tag :type="statusTagType(row.status)">
              {{ statusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="170" align="center" fixed="right">
          <template #default="{ row }">
            <el-dropdown @command="(val) => updateStatus(row, val)">
              <el-button type="primary" size="small">
                更新状态
              </el-button>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item command="pending">待处理</el-dropdown-item>
                  <el-dropdown-item command="processing">处理中</el-dropdown-item>
                  <el-dropdown-item command="resolved">已解决</el-dropdown-item>
                  <el-dropdown-item command="ignored">已忽略</el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { feedbackAPI, type FeedbackItem } from '../api/feedback'

const loading = ref(false)
const statusFilter = ref('')
const feedbackList = ref<FeedbackItem[]>([])

const fetchFeedback = async () => {
  loading.value = true
  try {
    const res = await feedbackAPI.list(statusFilter.value || undefined)
    feedbackList.value = res.data || []
  } catch (error) {
    console.error('Failed to fetch feedback:', error)
    ElMessage.error('获取反馈列表失败')
  } finally {
    loading.value = false
  }
}

const updateStatus = async (row: FeedbackItem, status: FeedbackItem['status']) => {
  try {
    await feedbackAPI.updateStatus(row.id, status)
    row.status = status
    ElMessage.success('状态更新成功')
  } catch (error) {
    console.error('Failed to update feedback status:', error)
    ElMessage.error('状态更新失败')
  }
}

const statusText = (status: string) => {
  switch (status) {
    case 'pending':
      return '待处理'
    case 'processing':
      return '处理中'
    case 'resolved':
      return '已解决'
    case 'ignored':
      return '已忽略'
    default:
      return status
  }
}

const statusTagType = (status: string) => {
  switch (status) {
    case 'pending':
      return 'warning'
    case 'processing':
      return ''
    case 'resolved':
      return 'success'
    case 'ignored':
      return 'info'
    default:
      return 'info'
  }
}

const formatDate = (dateStr: string) => {
  return new Date(dateStr).toLocaleString('zh-CN')
}

onMounted(() => {
  fetchFeedback()
})
</script>

<style scoped>
.feedback-container {
  height: 100%;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
