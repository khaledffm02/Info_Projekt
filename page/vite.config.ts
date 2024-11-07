import path from "path";
import vue from "@vitejs/plugin-vue";
import { defineConfig } from "vite";

const modes = ["development", "production"] as const;
type Mode = (typeof modes)[number];

function parseMode(mode: string): Mode {
  if (!modes.includes(mode as Mode)) {
    throw new Error(`Invalid mode: ${mode}`);
  }
  return mode as Mode;
}

// https://vitejs.dev/config/
export default defineConfig((config) => {
  return {
    publicDir: path.resolve(__dirname, "../public"),
    plugins: [vue()],
    resolve: {
      alias: {},
    },
    build: { sourcemap: true, outDir: path.resolve(__dirname, "../public") },
    define: {},
    server: {
      host: true,
    },
  };
});
