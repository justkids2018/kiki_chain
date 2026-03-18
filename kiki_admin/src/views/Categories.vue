<template>
  <div class="categories-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>场景分类列表</span>
          <el-button type="primary" @click="handleAdd">
            <el-icon><Plus /></el-icon>
            新建分类
          </el-button>
        </div>
      </template>
      
      <el-table :data="categories" v-loading="loading" border>
        <el-table-column prop="icon" label="图标" width="80" align="center">
          <template #default="{ row }">
            <span style="font-size: 24px">{{ row.icon }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="cover_image" label="封面" width="100" align="center">
          <template #default="{ row }">
            <el-image
              v-if="row.cover_image"
              :src="row.cover_image"
              :preview-src-list="[row.cover_image]"
              fit="cover"
              style="width: 60px; height: 60px; border-radius: 8px"
              preview-teleported
            >
              <template #error>
                <div style="display: flex; align-items: center; justify-content: center; width: 100%; height: 100%; background: #f5f7fa; color: #909399; font-size: 12px">
                  无图
                </div>
              </template>
            </el-image>
            <span v-else style="color: #909399; font-size: 12px">未设置</span>
          </template>
        </el-table-column>
        <el-table-column prop="name" label="名称" width="150" />
        <el-table-column prop="description" label="描述" />
        <el-table-column prop="order" label="排序" width="80" align="center" />
        <el-table-column prop="scene_count" label="场景数" width="100" align="center" />
        <el-table-column prop="is_new" label="新标签" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="row.is_new ? 'success' : 'info'" size="small">
              {{ row.is_new ? '是' : '否' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" align="center" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
    
    <!-- 编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="600px"
    >
      <el-form :model="form" :rules="rules" ref="formRef" label-width="100px">
        <el-form-item label="名称" prop="name">
          <el-input v-model="form.name" placeholder="如：春节场景" />
        </el-form-item>
        <el-form-item label="图标" prop="icon">
          <el-input v-model="form.icon" placeholder="Emoji 图标，如：🎉" maxlength="2" />
        </el-form-item>
        <el-form-item label="封面图" prop="cover_image">
          <ImageUpload v-model="form.cover_image" folder="categories" />
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input v-model="form.description" type="textarea" :rows="3" />
        </el-form-item>
        <el-form-item label="排序" prop="order">
          <el-input-number v-model="form.order" :min="0" />
        </el-form-item>
        <el-form-item label="新标签">
          <el-switch v-model="form.is_new" />
        </el-form-item>
      </el-form>
      
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitting">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import { categoryAPI, type Category } from '../api/categories'
import ImageUpload from '../components/ImageUpload.vue'

const loading = ref(false)
const categories = ref<Category[]>([])
const dialogVisible = ref(false)
const dialogTitle = ref('新建分类')
const submitting = ref(false)
const formRef = ref<FormInstance>()
const currentId = ref('')

const form = reactive({
  name: '',
  icon: '',
  cover_image: '',
  description: '',
  order: 0,
  is_new: false
})

const rules: FormRules = {
  name: [{ required: true, message: '请输入名称', trigger: 'blur' }],
  icon: [{ required: true, message: '请输入图标', trigger: 'blur' }]
}

const fetchCategories = async () => {
  loading.value = true
  try {
    const res = await categoryAPI.list()
    categories.value = res.data.sort((a, b) => a.order - b.order)
  } catch (error) {
    console.error('Failed to fetch categories:', error)
  } finally {
    loading.value = false
  }
}

const handleAdd = () => {
  dialogTitle.value = '新建分类'
  currentId.value = ''
  Object.assign(form, {
    name: '',
    icon: '',
    cover_image: '',
    description: '',
    order: categories.value.length + 1,
    is_new: false
  })
  dialogVisible.value = true
}

const handleEdit = (row: Category) => {
  dialogTitle.value = '编辑分类'
  currentId.value = row.id
  Object.assign(form, {
    name: row.name,
    icon: row.icon,
    cover_image: row.cover_image,
    description: row.description,
    order: row.order,
    is_new: row.is_new
  })
  dialogVisible.value = true
}

const handleSubmit = async () => {
  if (!formRef.value) return
  
  await formRef.value.validate(async (valid) => {
    if (!valid) return
    
    submitting.value = true
    try {
      if (currentId.value) {
        await categoryAPI.update(currentId.value, form)
        ElMessage.success('更新成功')
      } else {
        await categoryAPI.create(form)
        ElMessage.success('创建成功')
      }
      
      dialogVisible.value = false
      fetchCategories()
    } catch (error) {
      console.error('Submit failed:', error)
    } finally {
      submitting.value = false
    }
  })
}

const handleDelete = async (row: Category) => {
  try {
    await ElMessageBox.confirm(`确定要删除分类"${row.name}"吗？`, '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    await categoryAPI.delete(row.id)
    ElMessage.success('删除成功')
    fetchCategories()
  } catch (error) {
    // User cancelled
  }
}

onMounted(() => {
  fetchCategories()
})
</script>

<style scoped>
.categories-container {
  height: 100%;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
