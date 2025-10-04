import { createConfigs } from '@retn0/eslint-config';
import { defineConfig } from 'eslint/config';

export default defineConfig([
  ...createConfigs({
    ts: false,
    react: false,
  }),
  {
    files: ['**/*.js'],
    rules: {
      'no-undef': ['off'],
    },
  },
]);
