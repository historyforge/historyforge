const { test } = require('node:test')
const assert = require('node:assert/strict')
const { buildSync } = require('esbuild')
const vm = require('node:vm')

test('nested Forge overlays retain scroll locking when closed out of order', () => {
  const output = { exports: {} }
  const document = { body: { style: { overflow: 'auto' } }, activeElement: null }
  const code = buildSync({ entryPoints: ['app/javascript/forge/openDialog.js'], bundle: true,
    platform: 'node', format: 'cjs', write: false }).outputFiles[0].text
  vm.runInNewContext(code, { module: output, exports: output.exports, document })
  const dialog = () => ({ showModal() {}, close() {} })
  const closePhotos = output.exports.openDialog(dialog())
  const closePlace = output.exports.openDialog(dialog())
  closePhotos()
  assert.equal(document.body.style.overflow, 'hidden')
  closePlace()
  assert.equal(document.body.style.overflow, 'auto')
})
