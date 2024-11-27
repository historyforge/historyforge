class SearchStorage {
  params = null;
  CACHE_KEY = "forgeSearch";

  constructor() {
    try {
      const rawParams = window.localStorage.getItem(this.CACHE_KEY);
      if (rawParams) {
        this.params = JSON.parse(rawParams);
      }
    } catch(error) {
      console.error(error)
    }
  }

  save(params) {
    this.params = params;
    window.localStorage.setItem(this.CACHE_KEY, JSON.stringify(this.params));
  }

  reset() {
    this.params = null;
    window.localStorage.removeItem(this.CACHE_KEY);
  }

  setYear(year) {
    if (this.params?.year === year) {
      return;
    }

    this.save({ people: year, s: null });
  }
}

const searchStorage = new SearchStorage();

export const search = function(state = {}, action) {
  if (action.type === "FORGE_INIT") {
    return forgeInit(state);
  }

  if (action.type === 'FORGE_RESET') {
    return forgeReset(state);
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

function forgeInit(state) {
  if (state.params?.people || state.params?.buildings) {
    return state; // forgeFiltersLoaded will set the filters once they've loaded
  }

  const { params } = searchStorage;
  if (params?.people && !params?.buildings) {
    return { ...state, year: params.people, params };
  }
  return state;
}

function forgeReset(state) {
  searchStorage.reset();
  return { years: state.years, params: { f: [], s: [], people: null, year: null } }
}

function forgeSetYear(state, action) {
  searchStorage.setYear(action.year);
  return { ...state, year: action.year, params: { ...state.params, people: action.year } }
}

function forgeFiltersLoaded(state, action) {
  const nextState = { filters: action.filters, year: state.year, years: state.years }
  if (state.params && state.params.s) {
    console.log("resetting filters", state.params)
    nextState.current = buildFilters(action.filters, state.params.s)
    nextState.params = buildParams(nextState, nextState.current)
  } else if (state.year) {
    nextState.params = { s: state.current || {}, people: state.year }
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
  const criteria = action.predicate.match(/null/) ? "1" : action.criteria;
  current[action.field] = { field: action.field, predicate: action.predicate, criteria }
  return { ...state, current, d: new Date().getTime(), params: buildParams(state, current) }
}

function buildParams({ filters, year }, current) {
  const params = { people: year, s: {} }
  Object.keys(current).forEach(key => {
    const config = filters[key]
    const filter = current[key]
    params.s[filter.predicate] = config.type === 'boolean' ? 1 : filter.criteria
  });
  searchStorage.save(params);
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
