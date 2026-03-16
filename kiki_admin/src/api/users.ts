import request from './request'

export interface User {
  uid: string
  name: string
  phone: string
  email: string
  role_type: number
  is_vip: boolean
  created_at: string
}

export interface UpdateUserRequest {
  name?: string
  password?: string
  is_vip?: boolean
}

export const userAPI = {
  list() {
    return request.get<any, { success: boolean; data: User[] }>('/api/v1/admin/users')
  },

  get(id: string) {
    return request.get<any, { success: boolean; data: User }>(`/api/v1/admin/users/${id}`)
  },

  update(id: string, data: UpdateUserRequest) {
    return request.patch<any, { success: boolean; data: any }>(`/api/v1/admin/users/${id}/update`, data)
  }
}
