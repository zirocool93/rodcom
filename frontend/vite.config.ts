import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";
import { VitePWA } from "vite-plugin-pwa";

export default defineConfig({
  plugins: [
    vue(),
    VitePWA({
      registerType: "autoUpdate",
      manifest: {
        name: "RodCom",
        short_name: "RodCom",
        description: "Прозрачная касса родительского комитета",
        theme_color: "#2563eb",
        background_color: "#ffffff",
        display: "standalone",
        start_url: "/",
        lang: "ru"
      }
    })
  ],
  server: {
    port: 5173
  }
});
