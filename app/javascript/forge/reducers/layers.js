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
    } catch (error) {
      console.error(error)
    }
  }

  add(layer) {
    console.log(`Adding layer ${layer}`)
    this.layers.add(layer);
    this.save();
  }

  remove(layer) {
    console.log(`Removing layer ${layer}`)
    this.layers.delete(layer);
    this.save();
  }

  isSelected(layer) {
    return this.layers.has(layer.id);
  }

  get active() {
    return this.layers.size > 0
  }

  save() {
    window.localStorage.setItem(this.CACHE_KEY, JSON.stringify([...this.layers]));
  }

  reset() {
    this.layers = new Set();
    this.save();
  }
}

const layerStorage = new LayerStorage();

export const layers = function (state = {}, action) {
  if (action.type === 'FORGE_INIT') {
    const nextLayers = state.layers.filter(layer => layer != null).map(layer => {
      layer.selected = layerStorage.isSelected(layer);
      return layer;
    });
    return { ...state, layers: nextLayers, active: layerStorage.active, layeredAt: new Date().getTime() };
  }

  if (action.type === "FORGE_FOCUS") {
    return { ...state, focusOnPoints: action.buildings };
  }

  if (action.type === "FORGE_FOCUSING") {
    return { ...state, focusing: true };
  }

  if (action.type === "FORGE_FOCUSED") {
    return { ...state, focusing: false };
  }

  if (action.type === "LAYERS_RESET") {
    layerStorage.reset();
    return { ...state, active: false, layeredAt: new Date().getTime() };
  }

  if (action.type === 'LAYER_TOGGLE') {
    const layer = state.layers.find(item => item && item.id === action.id)
    if (!layer) {
      console.warn(`Layer with id ${action.id} not found`);
      return state;
    }
    console.log(layer)
    layer.selected = !layer.selected
    if (layer.selected) {
      layerStorage.add(layer.id);
    } else {
      layerStorage.remove(layer.id);
    }
    return { ...state, layers: [...state.layers], active: layerStorage.active, layeredAt: new Date().getTime() }
  }

  if (action.type === 'LAYER_OPACITY') {
    const layer = state.layers.find(item => item && item.id === action.id)
    if (!layer) {
      console.warn(`Layer with id ${action.id} not found for opacity change`);
      return state;
    }
    layer.opacity = parseInt(action.opacity)
    return { ...state, layers: [...state.layers], opacityAt: new Date().getTime() }
  }

  return state
}

