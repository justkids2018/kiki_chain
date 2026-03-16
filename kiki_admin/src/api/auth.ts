import request from './request'

export interface LoginParams {
  identifier: string
  password: string
}

export interface LoginResponse {
  success: boolean
  data: {
    uid: string
    name: string
    token: string
    role_type: number
  }
  message: string
}

export const authAPI = {
  login(params: LoginParams) {
    return request.post<any, LoginResponse>('/api/v1/auth/login', params)
  },
  
  logout() {
    return request.post('/api/v1/auth/logout')
  }
}
