<template>
  <div class="scene-items-container">
    <!-- 场景详情卡片 -->
    <el-card class="scene-detail-card" v-if="sceneDetail">
      <template #header>
        <span style="font-size: 16px; font-weight: 500">场景详情</span>
      </template>
      <el-descriptions :column="2" border>
        <el-descriptions-item label="场景名称">
          {{ sceneDetail.name }} / {{ sceneDetail.name_en }}
        </el-descriptions-item>
        <el-descriptions-item label="所属分类">
          {{ categoryName }}
        </el-descriptions-item>
        <el-descriptions-item label="封面图片">
          <el-image
            v-if="sceneDetail.cover_image"
            :src="toCDNUrl(sceneDetail.cover_image)"
            fit="cover"
            style="width: 80px; height: 80px; border-radius: 4px"
            :preview-src-list="[toCDNUrl(sceneDetail.cover_image)]"
            preview-teleported
          />
        </el-descriptions-item>
        <el-descriptions-item label="互动大图">
          <el-image
            v-if="sceneDetail.interactive_image"
            :src="toCDNUrl(sceneDetail.interactive_image)"
            fit="cover"
            style="width: 80px; height: 80px; border-radius: 4px"
            :preview-src-list="[toCDNUrl(sceneDetail.interactive_image)]"
            preview-teleported
          />
        </el-descriptions-item>
        <el-descriptions-item label="描述" :span="2">
          {{ sceneDetail.description }}
        </el-descriptions-item>
        <el-descriptions-item label="情境说明" :span="2">
          {{ sceneDetail.context }}
        </el-descriptions-item>
        <el-descriptions-item label="排序">
          {{ sceneDetail.order }}
        </el-descriptions-item>
        <el-descriptions-item label="新标签">
          <el-tag :type="sceneDetail.is_new ? 'success' : 'info'" size="small">
            {{ sceneDetail.is_new ? '是' : '否' }}
          </el-tag>
        </el-descriptions-item>
      </el-descriptions>
    </el-card>

    <!-- 物品管理卡片 -->
    <el-card style="margin-top: 20px">
      <template #header>
        <div class="card-header">
          <div>
            <el-button @click="$router.back()" icon="ArrowLeft">返回</el-button>
            <span style="margin-left: 20px; font-size: 18px; font-weight: 500">
              {{ sceneName }} - 物品管理
            </span>
          </div>
          <div style="display: flex; gap: 12px">
            <el-button @click="handleRefresh" :loading="refreshing">刷新</el-button>
            <el-button type="primary" @click="handleAdd">
              <el-icon><Plus /></el-icon>
              新建物品
            </el-button>
          </div>
        </div>
      </template>

      <el-table :data="items" v-loading="loading" border>
        <el-table-column prop="image_url" label="图片" width="100" align="center">
          <template #default="{ row }">
            <el-image
              v-if="row.image_url"
              :src="toCDNUrl(row.image_url)"
              fit="cover"
              style="width: 60px; height: 60px; border-radius: 4px"
              :preview-src-list="[toCDNUrl(row.image_url)]"
              preview-teleported
            />
          </template>
        </el-table-column>
        <el-table-column prop="name_cn" label="中文名" width="120" />
        <el-table-column prop="name_en" label="英文名" width="120" />
        <el-table-column prop="pinyin" label="拼音" width="120" />
        <el-table-column prop="pronunciation" label="发音" width="120" />
        <el-table-column label="热区" width="150">
          <template #default="{ row }">
            <span v-if="row.hotspot">
              {{ row.hotspot.x }}, {{ row.hotspot.y }}, 
              {{ row.hotspot.width }}×{{ row.hotspot.height }}
            </span>
            <el-tag v-else type="info" size="small">未设置</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="order" label="排序" width="80" align="center" />
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
      width="700px"
    >
      <el-form :model="form" :rules="rules" ref="formRef" label-width="120px">
        <el-form-item label="中文名称" prop="name_cn">
          <el-input v-model="form.name_cn" placeholder="如：灯笼" />
        </el-form-item>
        <el-form-item label="英文名称" prop="name_en">
          <el-input v-model="form.name_en" placeholder="如：Lantern" />
        </el-form-item>
        <el-form-item label="拼音" prop="pinyin">
          <el-input v-model="form.pinyin" placeholder="如：dēng lóng" />
        </el-form-item>
        <el-form-item label="发音描述">
          <el-input v-model="form.pronunciation" placeholder="发音说明" />
        </el-form-item>
        <el-form-item label="物品图片" prop="image_url">
          <el-input v-model="form.image_url" placeholder="图片 URL" />
        </el-form-item>
        <el-form-item label="发音音频">
          <el-input v-model="form.audio_url" placeholder="音频 URL" />
        </el-form-item>
        <el-form-item label="数据文件">
          <el-input v-model="form.data_file" placeholder="互动数据 JSON 文件路径（可选）" />
        </el-form-item>
        <el-form-item label="热区坐标">
          <el-row :gutter="10">
            <el-col :span="6">
              <el-input-number v-model="form.hotspot_x" placeholder="X" :min="0" style="width: 100%" />
            </el-col>
            <el-col :span="6">
              <el-input-number v-model="form.hotspot_y" placeholder="Y" :min="0" style="width: 100%" />
            </el-col>
            <el-col :span="6">
              <el-input-number v-model="form.hotspot_width" placeholder="宽" :min="0" style="width: 100%" />
            </el-col>
            <el-col :span="6">
              <el-input-number v-model="form.hotspot_height" placeholder="高" :min="0" style="width: 100%" />
            </el-col>
          </el-row>
        </el-form-item>
        <el-form-item label="排序" prop="order">
          <el-input-number v-model="form.order" :min="0" />
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
import { ref, reactive, onMounted, computed } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import { itemAPI, type SceneItem } from '../api/items'
import { sceneAPI } from '../api/scenes'
import { categoryAPI, type Category } from '../api/categories'
import { toCDNUrl } from '../utils/qiniu'

const route = useRoute()
const sceneId = computed(() => route.params.id as string)
const sceneName = ref('')
const sceneDetail = ref<any>(null)
const categories = ref<Category[]>([])
const loading = ref(false)
const refreshing = ref(false)
const items = ref<SceneItem[]>([])

const categoryName = computed(() => {
  if (!sceneDetail.value || !categories.value.length) return ''
  const cat = categories.value.find(c => c.id === sceneDetail.value.category_id)
  return cat ? cat.name : ''
})
const dialogVisible = ref(false)
const dialogTitle = ref('新建物品')
const submitting = ref(false)
const formRef = ref<FormInstance>()
const currentId = ref('')

const form = reactive({
  name_cn: '',
  name_en: '',
  pinyin: '',
  pronunciation: '',
  image_url: '',
  audio_url: '',
  data_file: '',
  order: 0,
  hotspot_x: 0,
  hotspot_y: 0,
  hotspot_width: 0,
  hotspot_height: 0
})

const rules: FormRules = {
  name_cn: [{ required: true, message: '请输入中文名称', trigger: 'blur' }],
  name_en: [{ required: true, message: '请输入英文名称', trigger: 'blur' }],
  pinyin: [{ required: true, message: '请输入拼音', trigger: 'blur' }]
}

const fetchCategories = async () => {
  try {
    const res = await categoryAPI.list()
    categories.value = res.data
  } catch (error) {
    console.error('Failed to fetch categories:', error)
  }
}

const fetchScene = async () => {
  try {
    const res = await sceneAPI.get(sceneId.value)
    sceneName.value = res.data.name
    sceneDetail.value = res.data
  } catch (error) {
    console.error('Failed to fetch scene:', error)
  }
}

const fetchItems = async () => {
  loading.value = true
  try {
    const res = await itemAPI.list(sceneId.value)
    items.value = res.data.sort((a, b) => a.order - b.order)
  } catch (error) {
    console.error('Failed to fetch items:', error)
  } finally {
    loading.value = false
  }
}

const handleRefresh = async () => {
  refreshing.value = true
  try {
    await Promise.all([fetchScene(), fetchItems()])
    ElMessage.success('数据已刷新')
  } finally {
    refreshing.value = false
  }
}

const handleAdd = () => {
  dialogTitle.value = '新建物品'
  currentId.value = ''
  Object.assign(form, {
    name_cn: '',
    name_en: '',
    pinyin: '',
    pronunciation: '',
    image_url: '',
    audio_url: '',
    data_file: '',
    order: items.value.length + 1,
    hotspot_x: 0,
    hotspot_y: 0,
    hotspot_width: 100,
    hotspot_height: 100
  })
  dialogVisible.value = true
}

const handleEdit = (row: SceneItem) => {
  dialogTitle.value = '编辑物品'
  currentId.value = row.id
  Object.assign(form, {
    name_cn: row.name_cn,
    name_en: row.name_en,
    pinyin: row.pinyin,
    pronunciation: row.pronunciation,
    image_url: row.image_url,
    audio_url: row.audio_url,
    data_file: row.data_file || '',
    order: row.order,
    hotspot_x: row.hotspot?.x || 0,
    hotspot_y: row.hotspot?.y || 0,
    hotspot_width: row.hotspot?.width || 100,
    hotspot_height: row.hotspot?.height || 100
  })
  dialogVisible.value = true
}

const handleSubmit = async () => {
  if (!formRef.value) return
  
  await formRef.value.validate(async (valid) => {
    if (!valid) return
    
    submitting.value = true
    try {
      const data = {
        name_cn: form.name_cn,
        name_en: form.name_en,
        pinyin: form.pinyin,
        pronunciation: form.pronunciation,
        image_url: form.image_url,
        audio_url: form.audio_url,
        data_file: form.data_file,
        order: form.order,
        hotspot: {
          x: form.hotspot_x,
          y: form.hotspot_y,
          width: form.hotspot_width,
          height: form.hotspot_height
        }
      }
      
      if (currentId.value) {
        await itemAPI.update(currentId.value, data)
        ElMessage.success('更新成功')
      } else {
        await itemAPI.create(sceneId.value, data)
        ElMessage.success('创建成功')
      }
      
      dialogVisible.value = false
      fetchItems()
    } catch (error) {
      console.error('Submit failed:', error)
    } finally {
      submitting.value = false
    }
  })
}

const handleDelete = async (row: SceneItem) => {
  try {
    await ElMessageBox.confirm(`确定要删除物品"${row.name_cn}"吗？`, '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    await itemAPI.delete(row.id)
    ElMessage.success('删除成功')
    fetchItems()
  } catch (error) {
    // User cancelled
  }
}

onMounted(() => {
  fetchCategories()
  fetchScene()
  fetchItems()
})
</script>

<style scoped>
.scene-items-container {
  height: 100%;
}

.scene-detail-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
