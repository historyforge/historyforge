import {createLogger} from "redux-logger";
import {applyMiddleware, combineReducers, createStore} from "redux";

export const buildStore = (reducers, middleware) => {
    const loggerMiddleware = createLogger({collapsed: true})
    const combinedReducers = combineReducers(reducers)
    const appliedMiddlewares = applyMiddleware(loggerMiddleware, middleware)
    return createStore(combinedReducers, window.initialState, appliedMiddlewares)
}

