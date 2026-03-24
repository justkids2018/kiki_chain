<template>
  <div class="scenes-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <div class="header-left">
            <span>场景管理</span>
            <el-select
              v-model="selectedCategory"
              placeholder="筛选分类"
              clearable
              style="width: 200px; margin-left: 20px"
              @change="handleCategoryChange"
            >
              <el-option
                v-for="cat in categories"
                :key="cat.id"
                :label="cat.name"
                :value="cat.id"
              />
            </el-select>
          </div>
          <div style="display: flex; gap: 12px">
            <el-button @click="handleRefresh" :loading="loading">刷新</el-button>
            <el-button type="primary" @click="handleAdd">
              <el-icon><Plus /></el-icon>
              新建场景
            </el-button>
          </div>
        </div>
      </template>

      <el-table :data="scenes" v-loading="loading" border>
        <el-table-column label="序号" type="index" width="60" align="center" :index="(i: number) => (currentPage - 1) * pageSize + i + 1" />
        <el-table-column prop="cover_image" label="封面" width="100" align="center">
          <template #default="{ row }">
            <el-image
              v-if="row.cover_image"
              :src="toCDNUrl(row.cover_image)"
              fit="cover"
              style="width: 60px; height: 60px; border-radius: 4px"
              :preview-src-list="[toCDNUrl(row.cover_image)]"
              preview-teleported
            />
          </template>
        </el-table-column>
        <el-table-column prop="interactive_image" label="互动大图" width="100" align="center">
          <template #default="{ row }">
            <el-image
              v-if="row.interactive_image"
              :src="toCDNUrl(row.interactive_image)"
              fit="cover"
              style="width: 60px; height: 60px; border-radius: 4px"
              :preview-src-list="[toCDNUrl(row.interactive_image)]"
              preview-teleported
            />
          </template>
        </el-table-column>
        <el-table-column prop="name" label="中文名" width="150" />
        <el-table-column prop="name_en" label="英文名" width="150" />
        <el-table-column prop="description" label="描述" show-overflow-tooltip />
        <el-table-column prop="order" label="排序" width="80" align="center" />
        <el-table-column prop="is_new" label="新标签" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="row.is_new ? 'success' : 'info'" size="small">
              {{ row.is_new ? '是' : '否' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="250" align="center" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button type="info" size="small" @click="handleViewJson(row)">查看JSON</el-button>
            <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页组件 -->
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :page-sizes="[10, 20, 30, 50]"
          :total="total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handlePageChange"
        />
      </div>
    </el-card>

    <!-- 编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="700px"
    >
      <el-form :model="form" :rules="rules" ref="formRef" label-width="120px">
        <el-form-item label="所属分类" prop="category_id">
          <el-select v-model="form.category_id" placeholder="请选择分类">
            <el-option
              v-for="cat in categories"
              :key="cat.id"
              :label="cat.name"
              :value="cat.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="中文名称" prop="name">
          <el-input v-model="form.name" placeholder="如：贴春联" />
        </el-form-item>
        <el-form-item label="英文名称" prop="name_en">
          <el-input v-model="form.name_en" placeholder="如：Spring Couplets" />
        </el-form-item>
        <el-form-item label="封面图" prop="cover_image">
          <ImageUpload v-model="form.cover_image" folder="scenes" />
        </el-form-item>
        <el-form-item label="互动大图" prop="interactive_image">
          <ImageUpload v-model="form.interactive_image" folder="scenes" />
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input v-model="form.description" type="textarea" :rows="2" />
        </el-form-item>
        <el-form-item label="情境说明" prop="context">
          <el-input v-model="form.context" type="textarea" :rows="2" placeholder="场景背景/使用情境" />
        </el-form-item>
        <el-form-item label="排序" prop="order">
          <el-input-number v-model="form.order" :min="0" />
        </el-form-item>
        <el-form-item label="新标签">
          <el-switch v-model="form.is_new" />
        </el-form-item>
        <el-form-item label="是否可见">
          <el-switch v-model="form.is_visible" />
        </el-form-item>
        <el-form-item label="物品数据 JSON">
          <el-input
            v-model="itemsDataText"
            type="textarea"
            :rows="10"
            placeholder='输入 JSON 数组，例如：[{"type":"chinese","id":"item_01","index":1,"text":"猴子","text_pinyin":"hóu zi","text_english":"Monkey","coordinate":[...]}]'
          />
          <div style="margin-top: 8px; font-size: 12px; color: #909399">
            提示：粘贴完整的物品 JSON 数组，系统会自动计算物品数量
          </div>
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitting">确定</el-button>
      </template>
    </el-dialog>

    <!-- JSON 查看对话框 -->
    <el-dialog
      v-model="jsonDialogVisible"
      title="场景物品数据 JSON"
      width="800px"
    >
      <el-input
        v-model="jsonViewText"
        type="textarea"
        :rows="20"
        readonly
        style="font-family: 'Courier New', monospace; font-size: 13px"
      />
      <template #footer>
        <el-button @click="jsonDialogVisible = false">关闭</el-button>
        <el-button type="primary" @click="copyJson">复制</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import { sceneAPI, type Scene } from '../api/scenes'
import { categoryAPI, type Category } from '../api/categories'
import ImageUpload from '../components/ImageUpload.vue'
import { toCDNUrl } from '../utils/qiniu'

const loading = ref(false)
const scenes = ref<Scene[]>([])
const categories = ref<Category[]>([])
const selectedCategory = ref('')
const dialogVisible = ref(false)
const dialogTitle = ref('新建场景')
const submitting = ref(false)
const formRef = ref<FormInstance>()
const currentId = ref('')

// 分页相关
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

const form = reactive({
  category_id: '',
  name: '',
  name_en: '',
  cover_image: '',
  interactive_image: '',
  description: '',
  context: '',
  order: 0,
  is_new: false,
  is_visible: true
})

const itemsDataText = ref('')

// JSON 查看对话框
const jsonDialogVisible = ref(false)
const jsonViewText = ref('')

const rules: FormRules = {
  category_id: [{ required: true, message: '请选择分类', trigger: 'change' }],
  name: [{ required: true, message: '请输入中文名称', trigger: 'blur' }],
  name_en: [{ required: true, message: '请输入英文名称', trigger: 'blur' }]
}

const fetchCategories = async () => {
  try {
    const res = await categoryAPI.list()
    categories.value = res.data
  } catch (error) {
    console.error('Failed to fetch categories:', error)
  }
}

const fetchScenes = async () => {
  loading.value = true
  try {
    const params: any = {
      page: currentPage.value,
      pageSize: pageSize.value
    }

    if (selectedCategory.value) {
      params.categoryId = selectedCategory.value
    }

    const res = await sceneAPI.list(params)
    scenes.value = res.data.scenes.sort((a, b) => a.order - b.order)
    total.value = res.data.total
  } catch (error) {
    console.error('Failed to fetch scenes:', error)
    ElMessage.error('获取场景列表失败')
  } finally {
    loading.value = false
  }
}

const handleCategoryChange = () => {
  currentPage.value = 1 // 重置到第一页
  fetchScenes()
}

const handlePageChange = (page: number) => {
  currentPage.value = page
  fetchScenes()
}

const handleSizeChange = (size: number) => {
  pageSize.value = size
  currentPage.value = 1 // 重置到第一页
  fetchScenes()
}

const handleRefresh = () => {
  fetchScenes()
}

const handleAdd = () => {
  dialogTitle.value = '新建场景'
  currentId.value = ''
  Object.assign(form, {
    category_id: selectedCategory.value || '',
    name: '',
    name_en: '',
    cover_image: '',
    interactive_image: '',
    data_file: '',
    description: '',
    context: '',
    order: scenes.value.length + 1,
    is_new: false,
    is_visible: true
  })
  itemsDataText.value = ''
  dialogVisible.value = true
}

const handleEdit = (row: Scene) => {
  dialogTitle.value = '编辑场景'
  currentId.value = row.id
  Object.assign(form, {
    category_id: row.category_id,
    name: row.name,
    name_en: row.name_en,
    cover_image: row.cover_image,
    interactive_image: row.interactive_image,
    data_file: row.data_file || '',
    description: row.description,
    context: row.context,
    order: row.order,
    is_new: row.is_new,
    isVisible: row.is_visible !== undefined ? row.is_visible : true
  })
  // 如果有 items_data，格式化显示
  itemsDataText.value = row.items_data ? JSON.stringify(row.items_data, null, 2) : ''
  dialogVisible.value = true
}

const handleSubmit = async () => {
  if (!formRef.value) return

  await formRef.value.validate(async (valid) => {
    if (!valid) return

    submitting.value = true
    try {
      // 解析 JSON
      let itemsData = null
      if (itemsDataText.value.trim()) {
        try {
          itemsData = JSON.parse(itemsDataText.value)
        } catch (e) {
          ElMessage.error('物品数据 JSON 格式错误，请检查')
          submitting.value = false
          return
        }
      }

      const payload = {
        ...form,
        items_data: itemsData
      }

      if (currentId.value) {
        await sceneAPI.update(currentId.value, payload)
        ElMessage.success('更新成功')
      } else {
        await sceneAPI.create(payload)
        ElMessage.success('创建成功')
      }

      dialogVisible.value = false
      fetchScenes()
    } catch (error) {
      console.error('Submit failed:', error)
    } finally {
      submitting.value = false
    }
  })
}

const handleDelete = async (row: Scene) => {
  try {
    await ElMessageBox.confirm(`确定要删除场景"${row.name}"吗？`, '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    await sceneAPI.delete(row.id)
    ElMessage.success('删除成功')
    fetchScenes()
  } catch (error) {
    // User cancelled
  }
}

const handleViewJson = (row: Scene) => {
  if (row.items_data) {
    jsonViewText.value = JSON.stringify(row.items_data, null, 2)
  } else {
    jsonViewText.value = '// 该场景暂无物品数据'
  }
  jsonDialogVisible.value = true
}

const copyJson = async () => {
  try {
    await navigator.clipboard.writeText(jsonViewText.value)
    ElMessage.success('已复制到剪贴板')
  } catch (error) {
    ElMessage.error('复制失败')
  }
}

onMounted(() => {
  fetchCategories()
  fetchScenes()
})
</script>

<style scoped>
.scenes-container {
  height: 100%;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-left {
  display: flex;
  align-items: center;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}
</style>
