import request from './request'

export interface Scene {
  id: string
  category_id: string
  category_ids?: string[]
  name: string
  name_en: string
  cover_image: string
  interactive_image: string
  data_file?: string
  description: string
  context: string
  order: number
  is_new: boolean
  is_visible: boolean
  item_count: number
  items_data?: any // JSON 数组
  created_at: string
}

export const sceneAPI = {
  list(params?: { page?: number; pageSize?: number; categoryId?: string }) {
    return request.get<any, { success: boolean; data: { scenes: Scene[]; total: number; page: number; page_size: number } }>('/api/v1/admin/scene/scenes', { params })
  },
  
  get(id: string) {
    return request.get<any, { success: boolean; data: Scene }>(`/api/v1/admin/scene/scenes/${id}`)
  },
  
  create(data: Partial<Scene> & { category_ids?: string[] }) {
    return request.post('/api/v1/admin/scene/scenes', data)
  },
  
  update(id: string, data: Partial<Scene> & { category_ids?: string[] }) {
    return request.put(`/api/v1/admin/scene/scenes/${id}`, data)
  },
  
  delete(id: string) {
    return request.delete(`/api/v1/admin/scene/scenes/${id}`)
  }
}
