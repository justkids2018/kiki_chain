import request from '../api/request'
import * as qiniu from 'qiniu-js'

/** CDN 原始域名 */
const CDN_ORIGIN = 'http://img.mtrain.xyz/'

/**
 * 将 CDN 绝对 HTTP URL 转换为相对代理路径 /cdn/...
 * 生产环境：nginx /cdn/ 代理到 http://img.mtrain.xyz/（避免混合内容）
 * 本地开发：Vite proxy /cdn/ 代理到同一地址
 * 移动端 / 数据库存储：保持原始 http:// URL 不变
 */
export function toCDNUrl(url: string | null | undefined): string {
  if (!url) return ''
  return url.startsWith(CDN_ORIGIN)
    ? '/cdn/' + url.slice(CDN_ORIGIN.length)
    : url
}

/**
 * 压缩图片（仅降低质量，不修改尺寸）
 * 依次尝试 quality 0.92 → 0.82 → 0.72 → 0.62 → 0.50
 * 若仍超出目标大小，使用最低质量结果
 * @param file 原始图片文件
 * @param targetKB 目标大小（KB），默认 200
 */
export async function compressImage(file: File, targetKB: number = 200): Promise<File> {
  const TARGET = targetKB * 1024
  if (file.size <= TARGET) return file

  return new Promise((resolve, reject) => {
    const img = new Image()
    const objectUrl = URL.createObjectURL(file)

    img.onload = () => {
      URL.revokeObjectURL(objectUrl)

      const canvas = document.createElement('canvas')
      const ctx = canvas.getContext('2d')!
      // 保持原始尺寸，不做任何缩放
      canvas.width = img.naturalWidth
      canvas.height = img.naturalHeight
      ctx.drawImage(img, 0, 0)

      const qualities = [0.92, 0.82, 0.72, 0.62, 0.50]
      const mimeType = file.type === 'image/png' ? 'image/png' : 'image/jpeg'
      const ext = file.type === 'image/png' ? 'png' : 'jpg'
      const outName = file.name.replace(/\.[^.]+$/, `.${ext}`)

      const tryQuality = (idx: number) => {
        canvas.toBlob(
          (blob) => {
            if (!blob) {
              reject(new Error('图片压缩失败'))
              return
            }
            if (blob.size <= TARGET || idx >= qualities.length - 1) {
              resolve(new File([blob], outName, { type: mimeType }))
            } else {
              tryQuality(idx + 1)
            }
          },
          mimeType,
          qualities[idx]
        )
      }

      tryQuality(0)
    }

    img.onerror = () => {
      URL.revokeObjectURL(objectUrl)
      reject(new Error('图片读取失败'))
    }

    img.src = objectUrl
  })
}

/**
 * 将文件名规范化为英文+数字（去除中文、空格及特殊字符）
 * 结果示例: "Spring Couplets 2024" → "spring_couplets_2024"
 */
export function sanitizeName(name: string): string {
  return (
    name
      .trim()
      .toLowerCase()
      // 中文及连续空白 → 下划线
      .replace(/[\u4e00-\u9fa5\s]+/g, '_')
      // 去除非 ASCII 字母/数字/下划线/连字符
      .replace(/[^a-z0-9_-]/g, '')
      // 合并连续下划线，去掉首尾下划线
      .replace(/_+/g, '_')
      .replace(/^_|_$/g, '') || 'image'
  )
}

/**
 * 从后端获取七牛云上传凭证
 */
async function getUploadToken(): Promise<string> {
  const response = await request.get('/api/v1/admin/upload/token')
  return response.data.token
}

/**
 * 上传文件到七牛云（使用官方 SDK）
 * @param file 文件对象
 * @param folder 存储文件夹
 * @param onProgress 上传进度回调
 * @returns 文件 URL
 */
export async function uploadToQiniu(
  file: File,
  folder: string = 'images',
  onProgress?: (percent: number) => void,
  customName?: string
): Promise<string> {
  // 1. 从后端获取上传凭证
  const token = await getUploadToken()

  // 2. 生成文件名: {name}_{timestamp}.{ext}
  const extension = file.name.split('.').pop() || 'jpg'
  const baseName = customName ? sanitizeName(customName) : 'image'
  const timestamp = Date.now()
  const key = `kiki/${folder}/${baseName}_${timestamp}.${extension}`

  // 3. 配置上传参数
  const putExtra = {
    fname: file.name,
    mimeType: file.type || 'image/jpeg',
  }

  const config = {
    useCdnDomain: true,
    region: qiniu.region.z2, // 华南区域
  }

  // 4. 创建上传 observable
  const observable = qiniu.upload(file, key, token, putExtra, config)

  // 5. 返回 Promise
  return new Promise((resolve, reject) => {
    observable.subscribe({
      next(res) {
        // 上传进度
        if (onProgress && res.total) {
          onProgress(Math.round(res.total.percent))
        }
      },
      error(err) {
        console.error('七牛云上传错误:', err)
        reject(new Error(err.message || '上传失败'))
      },
      complete(res) {
        console.log('七牛云上传成功:', res)
        // 返回完整的 CDN URL（使用 HTTP）
        const url = `http://img.mtrain.xyz/${res.key}`
        resolve(url)
      },
    })
  })
}
