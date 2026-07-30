import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { IMAGE_CDN_ORIGIN } from './src/config/image-cdn'

// https://vite.dev/config/
export default defineConfig({
  plugins: [vue()],
  server: {
    proxy: {
      // 本地开发：API 代理到后端（解决 CORS 跨域问题）
      '/api': {
        target: 'http://127.0.0.1:8081',
        changeOrigin: true
      },
      // 本地开发：所有当前与历史图片路径统一代理到当前 CDN。
      '/cdn': {
        target: IMAGE_CDN_ORIGIN,
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/cdn/, '')
      }
    }
  }
})
