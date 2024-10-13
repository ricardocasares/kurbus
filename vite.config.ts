import pkg from './package.json'
import {defineConfig} from 'vite'
import elm from 'vite-plugin-elm'
import {VitePWA} from 'vite-plugin-pwa'
import tspaths from 'vite-tsconfig-paths'

export default defineConfig({
  plugins: [
    elm(),
    tspaths(),
    VitePWA({
      registerType: 'autoUpdate',
      manifest: {
        name: pkg.name,
        short_name: pkg.name,
        background_color: '#000000',
        icons: [
          {
            src: 'pwa-64x64.png',
            sizes: '64x64',
            type: 'image/png',
          },
          {
            src: 'pwa-192x192.png',
            sizes: '192x192',
            type: 'image/png',
          },
          {
            src: 'pwa-512x512.png',
            sizes: '512x512',
            type: 'image/png',
          },
          {
            src: 'pwa-512x512.png',
            sizes: '512x512',
            type: 'image/png',
            purpose: 'any maskable',
          },
        ],
      },
    }),
  ],
  server: {
    proxy: {
      '/api': 'http://localhost:3000',
    },
  },
})
