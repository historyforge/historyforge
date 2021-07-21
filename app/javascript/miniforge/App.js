import React from 'react'
import Layers from "./Layers"
import Map from './Map'
import Buildings from './Buildings'
import ErrorBoundary from "../forge/ErrorBoundary";

import { createLogger } from 'redux-logger'
import { createStore, applyMiddleware, combineReducers } from 'redux'
import { Provider } from 'react-redux'
import { layers, buildings, buildingTypes, search } from "./reducers"
import { forgeMiddleware } from "./middlewares";

const buildStore = () => {
    const loggerMiddleware = createLogger({collapsed: true})
    const reducers = combineReducers({ layers, buildings, buildingTypes, search })
    return createStore(reducers, window.initialState, applyMiddleware(loggerMiddleware, forgeMiddleware))
}

export default class App extends React.PureComponent {
    mapRef = React.createRef()
    store = buildStore()
    render() {
        return (
            <ErrorBoundary>
                <Provider store={this.store}>
                    <div className={'map-wrap'}>
                        <Map />
                        <div id={'miniforge-controls'}>
                            <Layers />
                            <Buildings />
                        </div>
                    </div>
                </Provider>
            </ErrorBoundary>
        )
    }

    get map() {
        return this.mapRef.current.state.map
    }
}
