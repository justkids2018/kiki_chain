import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

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
      // 本地开发：/cdn/ → http://img.mtrain.xyz/（解决 HTTP 图片加载问题）
      '/cdn': {
        target: 'http://img.mtrain.xyz',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/cdn/, '')
      }
    }
  }
})
