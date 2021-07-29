import React from 'react'
import Layers from "./Layers"
import Map from './Map'
import Search from './Search'
import Building from './Building'

import { Provider } from 'react-redux'
import * as reducers from "./reducers"
import {forgeMiddleware} from './middlewares'
import { buildStore } from "./store";

export default class App extends React.PureComponent {
    mapRef = React.createRef()
    store = buildStore(reducers, forgeMiddleware)
    state = { sidebar: true }
    render() {
        const { sidebar } = this.state
        return (
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
        )
    }

    get map() {
        return this.mapRef.current.state.map
    }
}
