import request from './request'

export interface UploadResponse {
  url: string
  folder: string
  filename: string
}

export const uploadAPI = {
  /**
   * 上传图片到七牛云
   * @param file 图片文件
   * @param folder 存储文件夹（如 "categories", "scenes"）
   */
  uploadImage(file: File, folder: string = 'images') {
    const formData = new FormData()
    formData.append('file', file)
    formData.append('folder', folder)

    return request.post<any, { success: boolean; data: UploadResponse }>(
      '/api/v1/admin/upload/image',
      formData,
      {
        headers: {
          'Content-Type': 'multipart/form-data'
        }
      }
    )
  }
}
