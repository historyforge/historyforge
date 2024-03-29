import { createLogger } from 'redux-logger'
import { applyMiddleware, combineReducers, createStore } from 'redux'
import thunk from 'redux-thunk'
import { composeWithDevTools } from 'redux-devtools-extension'

export const buildStore = reducers => {
  const loggerMiddleware = createLogger({ collapsed: true })
  const combinedReducers = combineReducers(reducers)
  const appliedMiddlewares = composeWithDevTools(applyMiddleware(thunk, loggerMiddleware))

  return createStore(combinedReducers, window.initialState, appliedMiddlewares)
}
