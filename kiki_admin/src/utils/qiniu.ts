import request from '../api/request'
import * as qiniu from 'qiniu-js'

/** CDN 原始域名 */
const CDN_ORIGIN = 'http://img.mtrain.xyz/'
const CDN_HOST = 'img.mtrain.xyz'

/**
 * 将 CDN 绝对 HTTP URL 转换为相对代理路径 /cdn/...
 * 生产环境：nginx /cdn/ 代理到 http://img.mtrain.xyz/（避免混合内容）
 * 本地开发：Vite proxy /cdn/ 代理到同一地址
 * 移动端 / 数据库存储：保持原始 http:// URL 不变
 */
export function toCDNUrl(url: string | null | undefined): string {
  if (!url) return ''
  const raw = url.trim()

  // 已是代理路径时直接返回
  if (raw.startsWith('/cdn/')) return raw

  // 兼容存量相对路径：/kiki/scenes/... 或 kiki/scenes/...
  if (raw.startsWith('/kiki/')) return '/cdn' + raw
  if (raw.startsWith('kiki/')) return '/cdn/' + raw

  // 兼容异常存量：仅文件名（如 play_xxx.jpg）
  // 默认归入 scenes 目录，避免请求落到站点根路径触发 SPA 回退 HTML。
  if (/^[^/]+\.(jpg|jpeg|png|webp|gif|bmp|svg)(\?.*)?$/i.test(raw)) {
    return '/cdn/kiki/scenes/' + raw
  }

  // 兼容不同协议、大小写、query/hash 等 URL 形式
  try {
    const parsed = new URL(raw)
    if (parsed.hostname.toLowerCase() === CDN_HOST) {
      return `/cdn${parsed.pathname}${parsed.search}${parsed.hash}`
    }
  } catch {
    // 非法 URL 保持原值，避免吞掉真实问题
  }

  // 兜底：保留原先精确前缀匹配行为
  return raw.startsWith(CDN_ORIGIN) ? '/cdn/' + raw.slice(CDN_ORIGIN.length) : raw
}

/**
 * 压缩图片（仅降低质量，不修改尺寸）
 * 反复压缩：优先追求目标大小，最多允许到硬上限
 * - 优先保留原格式；若 PNG 无法达标，自动尝试 JPEG
 * - 不修改像素尺寸，只调整编码质量
 * - 若最低质量仍超过硬上限，则抛错，阻止上传
 * @param file 原始图片文件
 * @param targetKB 目标大小（KB），默认 150
 * @param maxAllowedKB 硬上限（KB），默认 160
 */
export async function compressImage(
  file: File,
  targetKB: number = 150,
  maxAllowedKB: number = 160
): Promise<File> {
  const TARGET = targetKB * 1024
  const HARD_MAX = maxAllowedKB * 1024
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

      const toBlob = (mimeType: string, quality?: number): Promise<Blob> =>
        new Promise((ok, fail) => {
          canvas.toBlob(
            (blob) => {
              if (!blob) {
                fail(new Error('图片压缩失败'))
                return
              }
              ok(blob)
            },
            mimeType,
            quality
          )
        })

      const runCompress = async (mimeType: string, ext: 'png' | 'jpg') => {
        const outName = file.name.replace(/\.[^.]+$/, `.${ext}`)

        // PNG 质量参数无效，先试一次原编码。
        if (mimeType === 'image/png') {
          const blob = await toBlob(mimeType)
          return {
            blob,
            file: new File([blob], outName, { type: mimeType }),
          }
        }

        // JPEG 反复降质量直到达标。
        let bestBlob: Blob | null = null
        let quality = 0.92
        const minQuality = 0.06
        const step = 0.06

        while (quality >= minQuality) {
          const blob = await toBlob(mimeType, quality)
          bestBlob = blob
          if (blob.size <= TARGET) {
            return {
              blob,
              file: new File([blob], outName, { type: mimeType }),
            }
          }
          quality = Number((quality - step).toFixed(2))
        }

        return {
          blob: bestBlob!,
          file: new File([bestBlob!], outName, { type: mimeType }),
        }
      }

        ; (async () => {
          // 1) 原格式优先
          const preferPng = file.type === 'image/png'
          const first = await runCompress(preferPng ? 'image/png' : 'image/jpeg', preferPng ? 'png' : 'jpg')
          if (first.blob.size <= TARGET) {
            resolve(first.file)
            return
          }

          // 2) PNG 未达标时，降级为 JPEG 强压缩
          const second = await runCompress('image/jpeg', 'jpg')
          if (second.blob.size <= TARGET) {
            resolve(second.file)
            return
          }

          // 3) 若未达到目标，但已在硬上限以内，允许上传
          if (second.blob.size <= HARD_MAX) {
            resolve(second.file)
            return
          }

          reject(
            new Error(
              `图片无法压缩到 ${maxAllowedKB}KB 以内（当前最小约 ${Math.round(second.blob.size / 1024)}KB）`
            )
          )
        })().catch(reject)
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
