const assert = require('node:assert/strict')
const { test } = require('node:test')
const vm = require('node:vm')
const { buildSync } = require('esbuild')

const code = buildSync({
  entryPoints: ['app/javascript/controllers/autocomplete_controller.js'],
  bundle: true, platform: 'node', format: 'cjs', write: false,
  external: ['stimulus']
}).outputFiles[0].text

test('a cancelled response cannot replace results for newer input', async () => {
  const element = { value: 'Can', dataset: { autocompleteUrl: '/search/people' } }
  const requests = []
  const document = { baseURI: 'https://example.test', activeElement: element }
  const moduleStub = { exports: {} }
  vm.runInNewContext(code, {
    module: moduleStub, require: () => ({ Controller: class {} }),
    URL, document, AbortController,
    fetch: (url, { signal }) => new Promise(resolve => requests.push({ url, signal, resolve }))
  })
  const controller = new moduleStub.exports.default()
  controller.element = element
  const rendered = []
  controller.render = items => rendered.push(items)

  const older = controller.load('Can')
  controller.request.abort()
  element.value = 'Canal'
  const newer = controller.load('Canal')
  requests[1].resolve({ ok: true, json: async () => ['current'] })
  await newer
  requests[0].resolve({ ok: true, json: async () => ['stale'] })
  await older

  assert.deepEqual(rendered, [['current']])
  assert.equal(requests[1].url.searchParams.get('term'), 'Canal')
})
