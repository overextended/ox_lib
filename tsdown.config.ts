import { defineConfig, type UserConfig } from "tsdown";
import postBuild from "./scripts/postbuild.ts";
import joaatPlugin from "./scripts/joaat.ts";

const config: Record<string, UserConfig> = {
  resource: {
    outExtensions() {
      return { js: ".js" };
    },
    outputOptions: {
      keepNames: true,
      entryFileNames: "[name].js",
    },
    deps: {
      alwaysBundle: [/.*/],
      onlyBundle: false,
    },
    plugins: [joaatPlugin()],
  },

  client: {
    platform: "browser",
    target: "es2023",
    format: "esm",
  },

  server: {
    platform: "node",
    format: "esm",
    outDir: "./dist/server",
  },
};

function createConfig(name: string): UserConfig {
  return {
    name,
    entry: {
      [name]: `./src/${name}.ts`,
    },
    tsconfig: `./tsconfig.${name}.json`,
    ...config.resource,
    ...config[name],
    onSuccess: postBuild,
  };
}

export default defineConfig([createConfig("client"), createConfig("server")]);
