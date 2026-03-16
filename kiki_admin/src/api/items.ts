import request from './request'

export interface SceneItem {
  id: string
  scene_id: string
  name_cn: string
  name_en: string
  pinyin: string
  pronunciation: string
  image_url: string
  audio_url: string
  data_file?: string
  order: number
  hotspot?: {
    x: number
    y: number
    width: number
    height: number
  }
  created_at: string
}

export const itemAPI = {
  list(sceneId: string) {
    return request.get<any, { success: boolean; data: SceneItem[] }>(`/api/v1/admin/scene/scenes/${sceneId}/items`)
  },
  
  get(id: string) {
    return request.get<any, { success: boolean; data: SceneItem }>(`/api/v1/admin/scene/items/${id}`)
  },
  
  create(sceneId: string, data: Partial<SceneItem>) {
    return request.post(`/api/v1/admin/scene/scenes/${sceneId}/items`, data)
  },
  
  update(id: string, data: Partial<SceneItem>) {
    return request.put(`/api/v1/admin/scene/items/${id}`, data)
  },
  
  delete(id: string) {
    return request.delete(`/api/v1/admin/scene/items/${id}`)
  },
  
  reorder(sceneId: string, items: { id: string; order: number }[]) {
    return request.put(`/api/v1/admin/scene/scenes/${sceneId}/items/reorder`, { items })
  }
}
