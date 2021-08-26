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

export const search = function(state = window.initialState.search, action) {
    if (action.type === 'FORGE_SET_YEAR') {
        return {...state, year: action.year, params: {...state.params, people: action.year} }
    }

    if (action.type === 'FORGE_FILTERS_LOADED') {
        const nextState = {filters: action.filters, year: state.year, years: state.years}
        if (state.params && state.params.s) {
            nextState.current = buildFilters(action.filters, state.params.s)
            nextState.params = buildParams(nextState, nextState.current)
        }
        return nextState
    }

    if (action.type === 'FORGE_ADD_FILTER') {
        const current = state.current || {}
        const scopes = Object.keys(state.filters[action.filter].scopes)
        current[action.filter] = { field: action.filter, predicate: scopes[0], criteria: null }
        return {...state, current}
    }

    if (action.type === 'FORGE_REMOVE_FILTER') {
        const current = {...state.current}
        delete current[action.filter]
        return {...state, current, params: buildParams(state)}
    }

    if (action.type === 'FORGE_SET_FILTER') {
        const current = {...state.current}
        current[action.field]  = { field: action.field, predicate: action.predicate, criteria: action.criteria }
        return {...state, current, d: new Date().getTime(), params: buildParams(state, current)}
    }

    return state
}

function buildParams({filters, year}, current) {
    const params = { people: year, s: {} }
    Object.keys(current).forEach(key => {
        const config = filters[key]
        const filter = current[key]
        params.s[filter.predicate] = config.type === 'boolean' ? 1 : filter.criteria
    })
    return params
}

function buildFilters(filters, params) {
    const current = {}
    Object.keys(params).forEach(predicate => {
        Object.keys(filters).forEach(key => {
            const filter = filters[key]
            if (filter.scopes && filter.scopes[predicate]) {
                current[key] = { field: key, predicate: predicate, criteria: params[predicate]}
            }
        })
    })
    return current
}
