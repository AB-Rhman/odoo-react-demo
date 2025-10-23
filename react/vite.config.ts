import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react-swc'

// https://vitejs.dev/config/
export default defineConfig({
  // Ensure built assets are referenced under /react/ so they work behind the reverse proxy
  base: '/react/',
  plugins: [react()],
  server: {
    port: 5173,
    open: false
  },
  preview: {
    port: 5173
  },
  build: {
    sourcemap: true
  }
})
