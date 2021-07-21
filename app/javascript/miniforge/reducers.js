export const layers = function(state = {}, action) {

    if (action.type === 'LAYER_TOGGLE') {
        const layer = state.layers.find(item => item.id === action.id)
        return {...state, layers: [...state.layers], layer: layer, layeredAt: new Date().getTime()}
    }

    if (action.type === 'LAYER_OPACITY') {
        return {...state, opacity: action.opacity, opacityAt: new Date().getTime()}
    }

    return state
}

export const buildingTypes = function(state = {}, action) {
    return state
}

export const buildings = function(state = {}, action) {
    if (action.type === 'BUILDING_MOVED') {
        return {
            ...state, current: { ...state.current, ...action.point }
        }
    }

    if (action.type === 'BUILDING_HIGHLIGHT') {
        return {
            ...state,
            highlighted: state.highlighted === action.id ? null : action.id,
        }
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
