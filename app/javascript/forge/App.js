import React from 'react'
import Layers from "./Layers"
import Map from './Map'
import Search from './Search'
import Building from './Building'
import ErrorBoundary from "./ErrorBoundary";

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
    state = { sidebar: true }
    render() {
        const { sidebar } = this.state
        return (
            <ErrorBoundary>
                <Provider store={this.store}>
                    <div className={'map-wrap'}>
                        <Map />
                        <div id={'forge-right-col'} className={sidebar ? 'open' : 'closed'}>
                            <Layers />
                            <Search />
                        </div>
                        <button type="button"
                                id="forge-sidebar-toggle"
                                className="btn btn-primary"
                                onClick={() => this.setState({ sidebar: !sidebar })}>
                            <i className={`fa fa-chevron-${sidebar ? 'left' : 'right'}`} />
                        </button>
                        <Building />
                    </div>
                </Provider>
            </ErrorBoundary>
        )
    }

    get map() {
        return this.mapRef.current.state.map
    }
}
