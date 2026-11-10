module.exports = {
  root: true,
  env: { browser: true, es2022: true },
  parserOptions: { ecmaVersion: 'latest', sourceType: 'module', ecmaFeatures: { jsx: true } },
  plugins: ['react'],
  rules: {
    'no-undef': 'error',
    'no-unused-vars': ['error', { args: 'none', caughtErrors: 'none' }],
    'react/jsx-uses-react': 'error',
    'react/jsx-uses-vars': 'error'
  },
  overrides: [
    { files: ['app/javascript/cms.js'], env: { commonjs: true } }
  ]
}
