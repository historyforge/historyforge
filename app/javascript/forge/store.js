import { createLogger } from 'redux-logger'
import { applyMiddleware, combineReducers, createStore } from 'redux'
import thunk from 'redux-thunk'
import { composeWithDevTools } from 'redux-devtools-extension'

/**
 * @param {Record<string, Function>} reducers
 * @param {Record<string, object>} initialState State serialized on the map mount element.
 */
export const buildStore = (reducers, initialState) => {
  const loggerMiddleware = createLogger({ collapsed: true })
  const combinedReducers = combineReducers(reducers)
  const appliedMiddlewares = composeWithDevTools(applyMiddleware(thunk, loggerMiddleware))

  return createStore(combinedReducers, initialState, appliedMiddlewares)
}
