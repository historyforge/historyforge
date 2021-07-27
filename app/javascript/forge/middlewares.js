import axios from 'axios'
import buildParams from "../forge/buildParams";

let searchTimeout = null

export const forgeMiddleware = store => next => (incomingAction) => {
    if (incomingAction.type === 'BUILDING_LOAD') {
        axios.get('/buildings.json', {
            params: buildParams(incomingAction.params)
        }).then(json => {
            store.dispatch({type: 'BUILDING_LOADED', ...json.data})
        })
    } else if(incomingAction.type === 'BUILDING_SELECT') {
        const url = `/buildings/${incomingAction.id}.json`
        axios.get(url, {params: buildParams(incomingAction.params)}).then(json => {
            store.dispatch({type: 'BUILDING_SELECTED', building: json.data.data})
        })
    } else if (incomingAction.type === 'SEARCH') {
        clearTimeout(searchTimeout)
        const { term } = incomingAction
        searchTimeout = setTimeout(() => {
            axios.get('/search/buildings.json', { params: { term, unpaged: true }}).then(json => {
                store.dispatch({type: 'BUILDING_LOADED', buildings: json.data})
            })
        }, term === '' ? 1000 : 200)
    } else {
        next(incomingAction)
    }
}

