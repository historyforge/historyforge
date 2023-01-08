class LayerStorage {
  layers = new Set();
  CACHE_KEY = "forgeSelectedLayers"

  constructor() {
    try {
      const rawLayers = window.localStorage.getItem(this.CACHE_KEY);
      if (rawLayers) {
        JSON.parse(rawLayers).forEach(layer => this.layers.add(layer));
      }
      console.log("Restored layers", this.layers);
    } catch(error) {
      console.error(error)
    }
  }

  add(layer) {
    console.log(`Adding layer ${layer}`)
    this.layers.add(layer);
    this.save();
  }

  remove(layer) {
    this.layers.remove(layer);
    this.save();
  }

  isSelected(layer) {
    return this.layers.has(layer.id);
  }

  save() {
    window.localStorage.setItem(this.CACHE_KEY, JSON.stringify([...this.layers]));
  }
}

const layerStorage = new LayerStorage();

export const layers = function(state = {}, action) {
  if (action.type === 'FORGE_INIT') {
    const nextLayers = state.layers.map(layer => {
      layer.selected = layerStorage.isSelected(layer);
      return layer;
    });
    return { ...state, layers: nextLayers, layeredAt: new Date().getTime() };
  }

  if (action.type === 'LAYER_TOGGLE') {
    const layer = state.layers.find(item => item.id === action.id)
    layer.selected = !layer.selected
    if (layer.selected) {
      layerStorage.add(layer.id);
    } else {
      layerStorage.remove(layer.id);
    }
    return { ...state, layers: [...state.layers], layeredAt: new Date().getTime() }
  }

  if (action.type === 'LAYER_OPACITY') {
    const layer = state.layers.find(item => item.id === action.id)
    layer.opacity = parseInt(action.opacity)
    return { ...state, layers: [...state.layers], opacityAt: new Date().getTime() }
  }

  return state
}

