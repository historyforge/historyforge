import axios from 'axios'

let searchTimeout = null

export function loadBuildings(incomingAction, store) {
    axios.get('/buildings.json', {
        params: buildParams(incomingAction.params)
    }).then(json => {
        store.dispatch({type: 'BUILDING_LOADED', ...json.data})
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

export const forgeMiddleware = store => next => (incomingAction) => {
    if (incomingAction.type === 'BUILDING_LOAD') {
        loadBuildings(incomingAction, store);
    } else if(incomingAction.type === 'BUILDING_SELECT') {
        loadBuilding(incomingAction, store);
    } else if (incomingAction.type === 'SEARCH') {
        searchBuildings(incomingAction, store);
    } else {
        next(incomingAction)
    }
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
