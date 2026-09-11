const { test } = require('node:test')
const assert = require('node:assert/strict')
const { buildSync } = require('esbuild')
const vm = require('node:vm')
const moduleUnderTest = { exports: {} }
const code = buildSync({
  entryPoints: ['app/javascript/miniforge/reducers.js'],
  bundle: true, platform: 'node', format: 'cjs', write: false,
}).outputFiles[0].text
vm.runInNewContext(code, { module: moduleUnderTest, exports: moduleUnderTest.exports })

test('repeated hover or click keeps the same building highlighted until leave', () => {
  const reduce = moduleUnderTest.exports.buildings
  let state = { highlighted: null }
  for (const id of [9227, 9227, 9227, 9228, null]) {
    state = reduce(state, { type: 'BUILDING_HIGHLIGHT', id })
    assert.equal(state.highlighted, id)
  }
})
