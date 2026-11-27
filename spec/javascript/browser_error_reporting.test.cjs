const assert = require('node:assert/strict')
const { test } = require('node:test')
const vm = require('node:vm')
const { buildSync } = require('esbuild')

const code = buildSync({
  entryPoints: ['app/javascript/application.js'],
  bundle: true, platform: 'browser', format: 'iife', write: false,
  external: ['./js/*', './passkeys', './controllers', './loadMaps', '@hotwired/turbo-rails'],
}).outputFiles[0].text

function loadApplication() {
  const events = new EventTarget()
  const notices = []
  const window = {
    env: 'production',
    airbrakeCreds: { app_id: 1, api_key: 'test', host: 'https://airbrake.example.test' },
    addEventListener: events.addEventListener.bind(events),
    require: () => ({}),
    document: new EventTarget(),
    fetch(_url, { body }) {
      notices.push(JSON.parse(body))
      return Promise.resolve({ status: 204 })
    },
    setInterval() {},
    setTimeout() {},
  }
  window.window = window
  vm.runInNewContext(code, window)

  function reportError({ message = '', filename = '', lineno = 0, colno = 0, error = null } = {}) {
    const event = Object.assign(new Event('error'), { message, filename, lineno, colno, error })
    // Browsers invoke both addEventListener callbacks and the legacy window.onerror handler.
    events.dispatchEvent(event)
    window.onerror?.(message, filename, lineno, colno, error)
  }

  return { events, notices, reportError }
}

test('window errors preserve the exception message and original stack', () => {
  const { notices, reportError } = loadApplication()
  const error = new TypeError('invalid map coordinates')
  reportError({ error, message: 'Uncaught TypeError: invalid map coordinates' })

  assert.equal(notices.length, 1)
  assert.equal(notices[0].context.windowError, true)
  const [reported] = notices[0].errors
  assert.equal(reported.type, 'TypeError')
  assert.equal(reported.message, error.message)
  assert.equal(reported.backtrace[0].file, __filename)
})

test('window errors without an exception report the browser-provided source location', () => {
  const { notices, reportError } = loadApplication()
  const filename = 'https://example.test/assets/application.js'
  reportError({ message: 'Unexpected identifier', filename, lineno: 12, colno: 34 })

  assert.equal(notices.length, 1)
  const [reported] = notices[0].errors
  assert.equal(reported.message, 'Unexpected identifier')
  assert.deepEqual(reported.backtrace, [{ function: '', file: filename, line: 12, column: 34 }])
})

test('empty window errors and opaque script errors do not send notices', () => {
  const { notices, reportError } = loadApplication()
  reportError()
  reportError({ message: 'Script error.' })

  assert.deepEqual(notices, [])
})

test('unhandled promise rejections report the reason once', () => {
  const { events, notices } = loadApplication()
  const reason = new Error('map layer failed to load')
  events.dispatchEvent(Object.assign(new Event('unhandledrejection'), { reason }))

  assert.equal(notices.length, 1)
  assert.equal(notices[0].context.unhandledRejection, true)
  assert.equal(notices[0].errors[0].message, reason.message)
})
