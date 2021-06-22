import { defineConfig } from "vite";
import { resolve } from "path";
import { VitePWA } from "vite-plugin-pwa";

export default defineConfig({
  base: "/lit-native/",
  plugins: [VitePWA()],
  build: {
    outDir: "build",
    lib: {
      entry: resolve(__dirname, "src/app.ts"),
      formats: ["es"],
      fileName: "bundle",
    },
    rollupOptions: {
      input: {
        main: resolve(__dirname, "index.html"),
      },
    },
  },
});
