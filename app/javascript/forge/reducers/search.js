export const search = function(state = {}, action) {
  if (action.type === 'FORGE_RESET') {
    return { years: state.years, params: { f: [], s: [], people: null, year: null } }
  }

  if (action.type === 'FORGE_SET_YEAR') {
    return forgeSetYear(state, action)
  }

  if (action.type === 'FORGE_FILTERS_LOADED') {
    return forgeFiltersLoaded(state, action)
  }

  if (action.type === 'FORGE_ADD_FILTER') {
    return forgeAddFilter(state, action)
  }

  if (action.type === 'FORGE_REMOVE_FILTER') {
    return forgeRemoveFilter(state, action)
  }

  if (action.type === 'FORGE_SET_FILTER') {
    return forgeSetFilter(state, action)
  }

  return state
}

function forgeSetYear(state, action) {
  return { ...state, year: action.year, params: { ...state.params, people: action.year } }
}

function forgeFiltersLoaded(state, action) {
  const nextState = { filters: action.filters, year: state.year, years: state.years }
  if (state.params && state.params.s) {
    nextState.current = buildFilters(action.filters, state.params.s)
    nextState.params = buildParams(nextState, nextState.current)
  } else if (state.year) {
    nextState.params = { s: {}, people: state.year }
  }
  return nextState
}

function forgeAddFilter(state, action) {
  const current = state.current || {}
  const scopes = Object.keys(state.filters[action.filter].scopes)
  current[action.filter] = { field: action.filter, predicate: scopes[0], criteria: null }
  return { ...state, current }
}

function forgeRemoveFilter(state, action) {
  const current = { ...state.current }
  delete current[action.filter]
  return { ...state, current, params: buildParams(state, current) }
}

function forgeSetFilter(state, action) {
  const current = { ...state.current }
  current[action.field] = { field: action.field, predicate: action.predicate, criteria: action.criteria }
  return { ...state, current, d: new Date().getTime(), params: buildParams(state, current) }
}

function buildParams({ filters, year }, current) {
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
        current[key] = { field: key, predicate: predicate, criteria: params[predicate] }
      }
    })
  })
  return current
}
