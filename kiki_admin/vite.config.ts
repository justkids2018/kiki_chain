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
      // 本地开发：/cdn/ → https://img.keepthinking.me/（解决 HTTPS 图片加载问题）
      '/cdn': {
        target: 'https://img.keepthinking.me',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/cdn/, '')
      },
      // 本地开发：/cdn-legacy/ → http://img.mtrain.xyz/（兼容旧域名资源）
      '/cdn-legacy': {
        target: 'http://img.mtrain.xyz',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/cdn-legacy/, '')
      }
    }
  }
})
