import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  root: '.',
  build: {
    rollupOptions: {
      input: 'app.html',
    },
  },
  server: {
    open: '/app.html',
    // Forward /api requests to the Express server
    // This means the frontend can call /api/tasks instead of http://localhost:3001/api/tasks
    proxy: {
      '/api':     'http://localhost:3001',
      '/uploads': 'http://localhost:3001', // avatar photos
    },
  },
})
