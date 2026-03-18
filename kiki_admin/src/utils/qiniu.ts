import request from '../api/request'
import * as qiniu from 'qiniu-js'

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
  onProgress?: (percent: number) => void
): Promise<string> {
  // 1. 从后端获取上传凭证
  const token = await getUploadToken()
  console.log('获取到的 token:', token)
  console.log('token 长度:', token.length)
  console.log('token 包含冒号数量:', (token.match(/:/g) || []).length)

  // 2. 生成唯一文件名
  const extension = file.name.split('.').pop() || 'jpg'
  const uuid = crypto.randomUUID()
  const key = `kiki/${folder}/${uuid}.${extension}`

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
    const subscription = observable.subscribe({
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
