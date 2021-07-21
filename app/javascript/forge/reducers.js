export const layers = function(state = {}, action) {

    if (action.type === 'LAYER_TOGGLE') {
        const layer = state.layers.find(item => item.id === action.id)
        layer.selected = !layer.selected
        return {...state, layers: [...state.layers], layeredAt: new Date().getTime()}
    }

    if (action.type === 'LAYER_OPACITY') {
        const layer = state.layers.find(item => item.id === action.id)
        layer.opacity = parseInt(action.opacity)
        return {...state, layers: [...state.layers], opacityAt: new Date().getTime()}
    }

    if (action.type === 'HEATMAP_OPACITY') {
        return {...state, heatmapOpacity: parseInt(action.opacity), heatmapOpacityAt: new Date().getTime()}
    }

    return state
}

export const buildingTypes = function(state = {}, action) {
    return state
}

export const buildings = function(state = {}, action) {
    if (action.type === 'BUILDING_HIGHLIGHT') {
        return {
            ...state,
            highlighted: state.highlighted === action.id ? null : action.id,
        }
    }

    if (action.type === 'BUILDING_LOADED') {
        const { buildings } = action
        return {...state, building: null, highlighted: null, buildings, loadedAt: new Date().getTime() }
    }

    if (action.type === 'BUILDING_SELECTED') {
        const { building } = action
        return { ...state, building, highlight: action.building.id }
    }

    return state
}

export const search = function(state = {}, action) {
    return state
}

// export const buildingTypes = function(state, action) {
//
// }
