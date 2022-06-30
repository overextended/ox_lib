import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  base: "./",
  build: {
    outDir: "build",
    target: "esnext",
  },
  esbuild: {
    logOverride: { "this-is-undefined-in-esm": "silent" },
  },
});
