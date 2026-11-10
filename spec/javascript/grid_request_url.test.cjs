const assert = require('node:assert/strict')
const { test } = require('node:test')
const vm = require('node:vm')
const { buildSync } = require('esbuild')

const code = buildSync({
  entryPoints: ['app/javascript/search/gridRequestURL.js'],
  format: 'cjs', write: false
}).outputFiles[0].text
const moduleStub = { exports: {} }
vm.runInNewContext(code, { module: moduleStub, URL })
const { gridRequestURL } = moduleStub.exports

test('grid requests preserve field and filter parameters and replace the previous sort', () => {
  const url = gridRequestURL('https://example.test/people?f[]=name&f[]=birth&s[last_name_eq]=Jones&sort[0][colId]=age', {
    startRow: 100,
    endRow: 200,
    sortModel: [{ colId: 'name', sort: 'desc' }, { colId: 'birth', sort: 'asc' }]
  })
  assert.deepEqual(url.searchParams.getAll('f[]'), ['name', 'birth'])
  assert.equal(url.searchParams.get('s[last_name_eq]'), 'Jones')
  assert.equal(url.searchParams.get('from'), '100')
  assert.equal(url.searchParams.get('to'), '200')
  assert.equal(url.searchParams.get('sort[0][colId]'), 'name')
  assert.equal(url.searchParams.get('sort[0][sort]'), 'desc')
  assert.equal(url.searchParams.get('sort[1][colId]'), 'birth')
  assert.equal(url.searchParams.get('sort[1][sort]'), 'asc')
})
