import axios from 'axios'

export const highlight = (id: number) => dispatch => {
  dispatch({ type: 'BUILDING_HIGHLIGHT', id })
}

export const setYear = (proposedYear?: number) => (dispatch, getState) => {
  let year = proposedYear || getState().search.params.people
  if (year) {
    year = parseInt(year)
    dispatch({ type: 'FORGE_SET_YEAR', year })
    dispatch(loadFilters(year))
    dispatch(load(getState().search.params))
  } else {
    dispatch(load())
  }
}

export const load = (params?: keyable) => async (dispatch, getState) => {
  // @ts-ignore
  const qs = params || getState().search.params || {}
  const json = await axios.get('/buildings.json', {
    params: buildParams(qs)
  })
  if (typeof json.data === 'string') { json.data = JSON.parse(json.data) }
  dispatch({ type: 'BUILDING_LOADED', ...json.data })
  const params = $.param(qs)
  const url = `/forge/?${params}`
  if (url !== location.toString()) {
    window.history.pushState(params, 'HistoryForge', url)
  }
}

export const select = (id: number, params?: keyable) => async (dispatch) => {
  const url = `/buildings/${id}.json`
  const json = await axios.get(url, { params: buildParams(params) })
  dispatch({ type: 'BUILDING_SELECTED', building: json.data })
}

export const address = (id: number) => async dispatch => {
  const url = `/buildings/${id}/address.json`
  const json = await axios.get(url)
  dispatch({ type: 'BUILDING_ADDRESS_LOADED', address: json.data })
}

export const deAddress = () => dispatch => {
  dispatch({ type: 'BUILDING_ADDRESS_REMOVE' })
}

export const moveBuilding = point => async dispatch => {
  configureAxios()
  const url = document.location.pathname + '.json'
  await axios.patch(url, { building: point })
  dispatch({ type: 'BUILDING_MOVED', point })
}

const loadFilters = year => async dispatch => {
  const url = `/census/${year}/advanced_search_filters.json`
  const json = await axios.get(url)
  dispatch({ type: 'FORGE_FILTERS_LOADED', ...json.data })
}

const buildParams = function(search: SearchParams) {
  const params = { s: {} } as SearchParams
  if (search && search.buildings) {
    params.s = search.s
  }
  if (search && search.people) {
    params.people = search.people
    params.peopleParams = search.s
  }
  params.s.lat_not_null = 1
  return params
}

const configureAxios = (): void => {
  axios.defaults.headers.common['X-CSRF-TOKEN'] = document.querySelector('[name=csrf-token]').getAttribute('content')
}
