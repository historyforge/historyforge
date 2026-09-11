const { test } = require('node:test')
const assert = require('node:assert/strict')
const vm = require('node:vm')
const { buildSync } = require('esbuild')

const code = buildSync({
  entryPoints: ['app/javascript/forge/hooks/useMapTargeting.js'],
  bundle: true, platform: 'node', format: 'cjs', write: false,
  external: ['react', 'react-redux', 'leaflet'],
}).outputFiles[0].text

for (const points of [[{ lat: 42, lon: -76 }], []]) {
  test(`location targeting preserves markers with ${points.length} nearby points`, () => {
    const effects = []
    const actions = []
    const views = []
    const markers = ['building-marker']
    const module = { exports: {} }
    const dependencies = {
      react: { useEffect: callback => effects.push(callback), useState: () => [null, () => {}] },
      'react-redux': {
        useDispatch: () => action => actions.push(action),
        useSelector: select => select({ layers: { focusOnPoints: points } }),
      },
      leaflet: { latLng: (lat, lon) => [lat, lon], latLngBounds: values => ({
        values, isValid: () => values.length > 0,
      }) },
    }
    vm.runInNewContext(code, { module, exports: module.exports, require: name => dependencies[name] })
    const operations = []
    const cluster = { clearLayers: () => { markers.length = 0 } }
    module.exports.useMapTargeting({
      hasLayer: group => group === cluster,
      removeLayer: group => { assert.equal(group, cluster); operations.push('detach') },
      fitBounds: (bounds, options) => {
        assert.equal(options.animate, false)
        operations.push('move')
        views.push(bounds)
      },
      addLayer: group => { assert.equal(group, cluster); operations.push('restore') },
    }, cluster)
    effects.forEach(effect => effect())
    assert.deepEqual(operations, points.length ? ['detach', 'move', 'restore'] : [])
    assert.deepEqual(markers, ['building-marker'])
    assert.equal(views.length, points.length ? 1 : 0)
    assert.equal(actions[0].type, 'FORGE_FOCUSED')
  })
}
