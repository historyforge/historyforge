import axios from 'axios'

export const highlight = (id: number | null) => dispatch => {
  dispatch({ type: 'BUILDING_HIGHLIGHT', id })
}

export const forgeInit = () => async (dispatch, getState) => {
  await dispatch({ type: "FORGE_INIT" });
  if (getState().search.params.buildings) {
    dispatch(load());
  } else {
    dispatch(setYear());
  }
}

export const setYear = (proposedYear?: number) => (dispatch, getState) => {
  let year = proposedYear || (getState().search.params.people)
  if (year) {
    year = parseInt(year)
    dispatch({ type: 'FORGE_SET_YEAR', year })
    dispatch(loadFilters(year))
    dispatch(load())
  } else {
    dispatch(load())
  }
}

let searchTimeout
export const searchTerm = (term) => async(dispatch) => {
  clearTimeout(searchTimeout)
  searchTimeout = setTimeout(() => {
    dispatch({ type: 'FORGE_RESET' })
    axios.get('/search/buildings.json', { params: { term, unpaged: true } }).then(json => {
      dispatch({ type: 'BUILDING_LOADED', buildings: json.data })
    })
  }, term === '' ? 1000 : 200)
}

export const getBuildingsNearMe = ({ latitude, longitude }: { latitude: number, longitude: number}) => async(dispatch, getState) => {
  const near = `${latitude}+${longitude}`;
  const qs = buildParams(getState().search || {});
  const params = {
    ...qs,
    near
  };
  const json = await axios.get('/buildings.json', { params })
  if (typeof json.data === 'string') { json.data = JSON.parse(json.data) }
  dispatch({ type: 'FORGE_FOCUS', buildings: json.data.buildings })
}

export const load = () => async (dispatch, getState) => {
  const qs = getState().search || {}
  const json = await axios.get('/buildings.json', {
    params: buildParams(qs)
  })
  if (typeof json.data === 'string') { json.data = JSON.parse(json.data) }
  dispatch({ type: 'BUILDING_LOADED', ...json.data })
  // const qsParams = $.param(qs)
  // const url = `/forge/?${qsParams}`
  // if (url !== location.toString()) {
  //   window.history.pushState(qsParams, 'HistoryForge', url)
  // }
}

export const reset = () => async (dispatch, getState) => {
  console.log("Resetting the Forge")
  await dispatch({ type: "FORGE_RESET" });
  return load()(dispatch, getState);
}

export const resetMap = () => async (dispatch) => {
    return dispatch({ type: "LAYERS_RESET" });
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

const buildParams = function(search: keyable) {
  const params = { s: {} } as keyable
  if (search?.params?.s) {
    params.s = search.params.s
  }
  if (search?.people?.s || search?.year) {
    params.people = search.people || search?.year
    params.peopleParams = search.params.s
  }
  params.s.lat_not_null = 1
  return params
}

const configureAxios = (): void => {
  axios.defaults.headers.common['X-CSRF-TOKEN'] = document.querySelector('[name=csrf-token]').getAttribute('content')
}
