export const layers = function(state = {}, action) {
  if (action.type === 'LAYER_TOGGLE') {
    const layer = state.layers.find(item => item.id === action.id)
    layer.selected = !layer.selected
    return { ...state, layers: [...state.layers], layeredAt: new Date().getTime() }
  }

  if (action.type === 'LAYER_OPACITY') {
    const layer = state.layers.find(item => item.id === action.id)
    layer.opacity = parseInt(action.opacity)
    return { ...state, layers: [...state.layers], opacityAt: new Date().getTime() }
  }

  return state
}
