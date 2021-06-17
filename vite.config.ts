import { defineConfig, UserConfigExport } from "vite";
import { resolve } from "path";
import { viteSingleFile } from "vite-plugin-singlefile";
import { VitePWA } from "vite-plugin-pwa";

export const singleFileConfig: UserConfigExport = {
  plugins: [viteSingleFile()],
  build: {
    outDir: "build",
    target: "esnext",
    assetsInlineLimit: 100000000,
    chunkSizeWarningLimit: 100000000,
    cssCodeSplit: false,
    brotliSize: false,
    rollupOptions: {
      input: {
        main: resolve(__dirname, "index.html"),
      },
      inlineDynamicImports: true,
      output: {
        manualChunks: () => "everything.js",
      },
    },
  },
};

export const multiFileConfig: UserConfigExport = {
  // base: "build",
  plugins: [VitePWA()],
  build: {
    outDir: "build",
    lib: {
      entry: "src/my-element.ts",
      formats: ["es"],
      fileName: 'bundle'
    },
    rollupOptions: {
      input: {
        main: resolve(__dirname, "index.html"),
      },
    },
  },
};

export default defineConfig(multiFileConfig);
