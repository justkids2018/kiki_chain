<template>
  <div class="image-upload">
    <div v-if="imageUrl" class="image-preview">
      <el-image :src="displayUrl" fit="cover" class="preview-image">
        <template #error>
          <div class="image-error">
            <el-icon><Picture /></el-icon>
            <span>加载失败</span>
          </div>
        </template>
      </el-image>
      <div class="image-actions">
        <el-button type="primary" size="small" :icon="Upload" @click="triggerUpload">更换图片</el-button>
        <el-button type="danger" size="small" :icon="Delete" @click="handleRemove">删除</el-button>
      </div>
    </div>
    <div v-else class="upload-placeholder" @click="triggerUpload">
      <el-icon class="upload-icon"><Plus /></el-icon>
      <div class="upload-text">点击上传图片</div>
      <div class="upload-hint">支持 JPG、PNG 格式，建议尺寸 800x600</div>
    </div>

    <input
      ref="fileInput"
      type="file"
      accept="image/*"
      style="display: none"
      @change="handleFileChange"
    />

    <el-progress
      v-if="uploading"
      :percentage="uploadProgress"
      :status="uploadProgress === 100 ? 'success' : undefined"
      style="margin-top: 10px"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, watch, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { Plus, Upload, Delete, Picture } from '@element-plus/icons-vue'
import { uploadToQiniu, toCDNUrl } from '../utils/qiniu'

interface Props {
  modelValue?: string
  folder?: string
}

interface Emits {
  (e: 'update:modelValue', value: string): void
}

const props = withDefaults(defineProps<Props>(), {
  modelValue: '',
  folder: 'images'
})

const emit = defineEmits<Emits>()

const imageUrl = ref(props.modelValue)
const displayUrl = computed(() => toCDNUrl(imageUrl.value))
const uploading = ref(false)
const uploadProgress = ref(0)
const fileInput = ref<HTMLInputElement>()

// 监听外部值变化
watch(() => props.modelValue, (newVal) => {
  imageUrl.value = newVal
})

// 触发文件选择
const triggerUpload = () => {
  fileInput.value?.click()
}

// 文件选择变化
const handleFileChange = async (event: Event) => {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]

  if (!file) return

  // 验证文件
  const isImage = file.type.startsWith('image/')
  const isLt5M = file.size / 1024 / 1024 < 5

  if (!isImage) {
    ElMessage.error('只能上传图片文件！')
    return
  }
  if (!isLt5M) {
    ElMessage.error('图片大小不能超过 5MB！')
    return
  }

  // 开始上传
  uploading.value = true
  uploadProgress.value = 0

  try {
    // 模拟进度
    const progressInterval = setInterval(() => {
      if (uploadProgress.value < 90) {
        uploadProgress.value += 10
      }
    }, 200)

    // 上传到七牛云
    const url = await uploadToQiniu(file, props.folder)

    clearInterval(progressInterval)
    uploadProgress.value = 100

    // 更新 URL
    imageUrl.value = url
    emit('update:modelValue', url)

    ElMessage.success('上传成功')
  } catch (error: any) {
    console.error('Upload error:', error)
    ElMessage.error(error.message || '上传失败，请重试')
  } finally {
    uploading.value = false
    uploadProgress.value = 0
    // 清空 input，允许重复上传同一文件
    if (target) target.value = ''
  }
}

// 删除图片
const handleRemove = () => {
  imageUrl.value = ''
  emit('update:modelValue', '')
}
</script>

<style scoped>
.image-upload {
  width: 100%;
}

.image-preview {
  position: relative;
  width: 200px;
  height: 150px;
  border-radius: 8px;
  overflow: hidden;
  border: 1px solid #dcdfe6;
}

.preview-image {
  width: 100%;
  height: 100%;
}

.image-error {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  width: 100%;
  height: 100%;
  background: #f5f7fa;
  color: #909399;
}

.image-error .el-icon {
  font-size: 32px;
  margin-bottom: 8px;
}

.image-actions {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  display: flex;
  gap: 8px;
  padding: 8px;
  background: rgba(0, 0, 0, 0.6);
  opacity: 0;
  transition: opacity 0.3s;
}

.image-preview:hover .image-actions {
  opacity: 1;
}

.upload-placeholder {
  width: 200px;
  height: 150px;
  border: 2px dashed #dcdfe6;
  border-radius: 8px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: border-color 0.3s;
}

.upload-placeholder:hover {
  border-color: #409eff;
}

.upload-icon {
  font-size: 32px;
  color: #8c939d;
  margin-bottom: 8px;
}

.upload-text {
  font-size: 14px;
  color: #606266;
  margin-bottom: 4px;
}

.upload-hint {
  font-size: 12px;
  color: #909399;
}
</style>
