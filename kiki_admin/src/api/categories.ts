import request from './request'

export interface Category {
  id: string
  name: string
  icon: string
  cover_image: string
  description: string
  order: number
  is_new: boolean
  scene_count: number
  total_item_count: number
  created_at: string
}

export const categoryAPI = {
  list() {
    return request.get<any, { success: boolean; data: Category[] }>('/api/v1/admin/scene/categories')
  },
  
  create(data: Partial<Category>) {
    return request.post('/api/v1/admin/scene/categories', data)
  },
  
  update(id: string, data: Partial<Category>) {
    return request.put(`/api/v1/admin/scene/categories/${id}`, data)
  },
  
  delete(id: string) {
    return request.delete(`/api/v1/admin/scene/categories/${id}`)
  }
}
