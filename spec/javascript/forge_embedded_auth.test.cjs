const { test } = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const vm = require('node:vm')

const source = fs.readFileSync('app/javascript/application.js', 'utf8')
const check = source.match(/function syncAuthStateWithHeader\(\) \{[\s\S]*?\n\}/)[0]

function reloadCount(header, signedIn, menu) {
  let reloads = 0
  const context = {
    document: { querySelector: selector => ({
      '#main-header': header ? {} : null,
      'meta[name="hf-auth"]': { content: signedIn ? 'signed-in' : 'signed-out' },
      '#main-header #user-menu-item': menu ? {} : null
    })[selector] },
    window: { location: { reload: () => reloads++ } }
  }
  vm.runInNewContext(`${check}; syncAuthStateWithHeader()`, context)
  return reloads
}

test('embedded signed-in records without a header do not enter a reload loop', () => {
  assert.equal(reloadCount(false, true, false), 0)
})
test('normal pages still reload a stale signed-in header', () => {
  assert.equal(reloadCount(true, false, true), 1)
  assert.equal(reloadCount(true, true, true), 0)
})
