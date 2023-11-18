import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import * as path from 'path';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  base: './',
  server: {
    port: 3000,
  },
  build: {
    outDir: 'build',
    target: 'esnext',
  },
  esbuild: {
    logOverride: { 'this-is-undefined-in-esm': 'silent' },
  },
});
