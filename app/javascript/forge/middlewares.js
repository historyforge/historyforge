import axios from 'axios'

let searchTimeout = null

export function loadBuildings(incomingAction, store) {
    const qs = incomingAction.params || store.getState().search.params || {}
    console.log(incomingAction, qs, buildParams(qs))
    axios.get('/buildings.json', {
        params: buildParams(qs)
    }).then(json => {
        if (typeof json.data === 'string')
            json.data = JSON.parse(json.data)
        store.dispatch({type: 'BUILDING_LOADED', ...json.data})
        const params = $.param(qs)
        const url = `/forge/?${params}`
        if (url !== location.toString()) {
            window.history.pushState(params, 'HistoryForge', url)
        }
    })
}

export function loadBuilding(incomingAction, store) {
    const url = `/buildings/${incomingAction.id}.json`
    axios.get(url, {params: buildParams(incomingAction.params)}).then(json => {
        store.dispatch({type: 'BUILDING_SELECTED', building: json.data})
    })
}

export function searchBuildings(incomingAction, store) {
    clearTimeout(searchTimeout)
    const {term} = incomingAction
    searchTimeout = setTimeout(() => {
        axios.get('/search/buildings.json', {params: {term, unpaged: true}}).then(json => {
            store.dispatch({type: 'BUILDING_LOADED', buildings: json.data})
        })
    }, term === '' ? 1000 : 200)
}

export function moveBuilding(incomingAction, store) {
    const url = document.location.pathname
    axios.patch(url, {
        building: incomingAction.point
    }).then(() => {
        store.dispatch({type: 'BUILDING_MOVED', point: incomingAction.point})
    })
}

function loadFilters(year, store) {
    const url = `/census/${year}/advanced_search_filters.json`
    axios.get(url).then(json => {
        store.dispatch({type: 'FORGE_FILTERS_LOADED', ...json.data })
    })
}

export const forgeMiddleware = store => next => (incomingAction) => {
    if (incomingAction.type === 'BUILDING_LOAD') {
        loadBuildings(incomingAction, store);
    } else if(incomingAction.type === 'BUILDING_SELECT') {
        loadBuilding(incomingAction, store);
    } else if (incomingAction.type === 'SEARCH') {
        searchBuildings(incomingAction, store);
    } else if (incomingAction.type === 'FORGE_SET_YEAR') {
        loadFilters(incomingAction.year, store)
    }
    next(incomingAction)
}

const buildParams = function(search) {
    const params = { s: {} }
    if (search.buildings) {
        params.s = search.s
    }
    if (search.people) {
        params.people = search.people
        params.peopleParams = search.s
    }
    params.s.lat_not_null = 1
    return params
}
