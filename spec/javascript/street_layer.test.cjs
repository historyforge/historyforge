const { test } = require('node:test')
const assert = require('node:assert/strict')
const vm = require('node:vm')
const fs = require('node:fs')
const { buildSync } = require('esbuild')

function setup() {
  let definition
  let options
  const events = {}
  let currentMap
  const layer = {
    on(name, callback) { events[name] = callback },
    getMaplibreMap() { return currentMap },
  }
  const leaflet = {
    Layer: { extend(value) { definition = value; return function () {} } },
    maplibreGL(value) { options = value; return layer },
  }
  // Exercise the installed wrapper's attribution implementation.
  vm.runInNewContext(fs.readFileSync(require.resolve('@maplibre/maplibre-gl-leaflet'), 'utf8'), {
    exports: {}, module: {}, require: name => name === 'leaflet' ? leaflet : {},
  })
  leaflet.maplibreGL = value => { options = value; return layer }
  const code = buildSync({
    entryPoints: ['app/javascript/forge/streetLayer.js'], bundle: true,
    platform: 'node', format: 'cjs', write: false,
    external: ['leaflet', '@maplibre/maplibre-gl-leaflet'],
  }).outputFiles[0].text
  const module = { exports: {} }
  vm.runInNewContext(code, { module, exports: module.exports, Uint8Array,
    require: name => name === 'leaflet' ? leaflet : {},
  })
  module.exports.createStreetLayer()
  return { options, definition, activate(map) { currentMap = map; events.add() } }
}

test('uses fixed provider credits without reading third-party source attribution', () => {
  const { options, definition } = setup()
  const attribution = definition.getAttribution.call({ options,
    _glMap: { getStyle() { throw new Error('must not read third-party metadata') } },
  })
  for (const provider of ['OpenFreeMap', 'OpenMapTiles', 'OpenStreetMap']) {
    assert.ok(attribution.includes(provider))
  }
})

test('reattaches house numbers and transparent image fallback on Street reactivation', () => {
  const { activate } = setup()
  for (let activation = 0; activation < 2; activation++) {
    const events = {}
    const layers = []
    const images = []
    const map = {
      on(name, callback) { events[name] = callback },
      once(name, callback) { events[name] = callback },
      isStyleLoaded: () => false,
      getLayer: id => id === 'label_other',
      getSource: id => id === 'openmaptiles',
      addLayer(...args) { layers.push(args) },
      addImage(...args) { images.push(args) },
    }
    activate(map)
    events.load()
    assert.equal(layers[0][0].id, 'housenumber')
    assert.equal(layers[0][0].minzoom, 17)
    assert.equal(layers[0][1], 'label_other')
    events.styleimagemissing({ id: 'missing-sprite' })
    assert.equal(images[0][0], 'missing-sprite')
    assert.equal(images[0][1].width, 1)
    assert.deepEqual(Array.from(images[0][1].data), [0, 0, 0, 0])
  }
})
