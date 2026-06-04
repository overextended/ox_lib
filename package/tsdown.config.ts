import { defineConfig } from 'tsdown';
import PreprocessorDirectives from 'unplugin-preprocessor-directives/rollup';

export default defineConfig({
  plugins: [PreprocessorDirectives()],
  entry: ['common/index.ts', 'client/index.ts', 'server/index.ts'],
  unbundle: true,
  outputOptions: {
    keepNames: true,
    entryFileNames: '[name].js',
  },
  deps: {
    skipNodeModulesBundle: true,
  },
  outExtensions() {
    return { js: '.js' };
  },
});
