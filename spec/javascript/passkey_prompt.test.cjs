const assert = require('node:assert/strict')
const { test } = require('node:test')
const vm = require('node:vm')
const { buildSync } = require('esbuild')

const code = buildSync({
  entryPoints: ['app/javascript/controllers/passkey_prompt_controller.js'],
  bundle: true, platform: 'node', format: 'cjs', write: false,
  external: ['stimulus', '../passkeys'],
}).outputFiles[0].text

function prompt({ supported = true, cookie = '' } = {}) {
  const module = { exports: {} }
  const document = { cookie }
  const element = new EventTarget()
  const calls = []
  class Modal {
    show() { calls.push('show') }
    hide() {
      calls.push('hide')
      element.dispatchEvent(new Event('hidden.bs.modal'))
    }
    dispose() { calls.push('dispose') }
  }
  vm.runInNewContext(code, {
    module,
    require: name => name === 'stimulus' ? { Controller: class {} } : {},
    document,
    window: { PublicKeyCredential: supported, bootstrap: { Modal } },
  })
  const controller = new module.exports.default()
  controller.element = element
  return { controller, document, element, calls }
}

test('leaving a page closes the passkey prompt without recording a dismissal', () => {
  const { controller, document, calls } = prompt()
  controller.connect()
  controller.disconnect()
  controller.disconnect()
  assert.deepEqual(calls, ['show', 'hide', 'dispose'])
  assert.equal(document.cookie, '')
})

test('dismissing the passkey prompt prevents it from opening on the next visit', () => {
  const { controller, document, element } = prompt()
  controller.connect()
  element.dispatchEvent(new Event('hidden.bs.modal'))
  assert.match(document.cookie, /^passkey_prompt_dismissed=1; Max-Age=2592000;/)
  const nextVisit = prompt({ cookie: 'another_cookie=1; passkey_prompt_dismissed=1' })
  nextVisit.controller.connect()
  assert.deepEqual(nextVisit.calls, [])
})

test('the prompt stays closed in browsers without passkey support', () => {
  const { controller, calls } = prompt({ supported: false })
  controller.connect()
  assert.deepEqual(calls, [])
})
