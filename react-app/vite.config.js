import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  base: '/react/', // Important! So it works correctly under /react path
  server: {
    host: true,
    port: 5173
  }
})
