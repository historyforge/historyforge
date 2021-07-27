import axios from 'axios'
import {loadBuilding, moveBuilding} from "../forge/middlewares";

const csrfMetaTag = document.getElementsByName('csrf-token')[0]
const token = csrfMetaTag ? csrfMetaTag.getAttribute('content') : null
if (token) {
    axios.defaults.headers.common['X-CSRF-Token'] = token
    axios.defaults.headers.common['Accept'] = 'application/json'
}

export const miniForgeMiddleware = store => next => (incomingAction) => {
    if (incomingAction.type === 'BUILDING_MOVE') {
        moveBuilding(incomingAction, store);
    } else if(incomingAction.type === 'BUILDING_SELECT') {
        loadBuilding(incomingAction, store);
    } else {
        next(incomingAction)
    }
}

