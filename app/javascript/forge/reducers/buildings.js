export const buildings = function(state = {}, action) {
    if (action.type === 'BUILDING_HIGHLIGHT') {
        return {
            ...state,
            highlighted: state.highlighted === action.id ? null : action.id,
        }
    }

    if (action.type === 'BUILDING_LOADED') {
        const { meta: {info}, buildings } = action
        return {...state, building: null, highlighted: null, buildings, message: info, loadedAt: new Date().getTime() }
    }

    if (action.type === 'BUILDING_SELECTED') {
        const { building } = action
        return { ...state, building, highlighted: null } //, highlighted: action.building.id }
    }

    if (action.type === 'BUILDING_DESELECT') {
        return { ...state, building: null, highlighted: null }
    }

    return state
}

