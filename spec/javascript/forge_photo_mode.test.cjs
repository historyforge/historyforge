const { test } = require('node:test')
const assert = require('node:assert/strict')
const { buildSync } = require('esbuild')
const vm = require('node:vm')

test('switching photo mode preserves search filters and ignores an older map response', async () => {
  const requests = []
  const output = { exports: {} }
  const axios = { get: (url, options) => new Promise(resolve => requests.push({ url, options, resolve })) }
  const code = buildSync({ entryPoints: ['app/javascript/forge/actions.js'], bundle: true,
    platform: 'node', format: 'cjs', external: ['axios'], write: false }).outputFiles[0].text
  vm.runInNewContext(code, { module: output, exports: output.exports, require: () => axios })
  let photoMode = false
  const events = []
  const getState = () => ({ buildings: { photoMode }, search: { year: 1910, params: { s: { sex_eq: 'F' } } } })
  const dispatch = action => {
    if (typeof action === 'function') return action(dispatch, getState)
    if (action.type === 'FORGE_PHOTOS') photoMode = action.enabled
    events.push(action)
  }
  const oldRequest = dispatch(output.exports.load())
  dispatch(output.exports.togglePhotos())
  assert.equal(requests[1].options.params.photos, '1')
  assert.equal(requests[1].options.params.people, 1910)
  assert.equal(requests[1].options.params.peopleParams.sex_eq, 'F')
  requests[1].resolve({ data: { buildings: [{ id: 2 }] } })
  await new Promise(resolve => setImmediate(resolve))
  requests[0].resolve({ data: { buildings: [{ id: 1 }] } })
  await oldRequest
  const loaded = events.filter(event => event.type === 'BUILDING_LOADED')
  assert.equal(loaded.length, 1)
  assert.equal(loaded[0].buildings[0].id, 2)
  assert.equal(loaded[0].photoMode, true)
})
