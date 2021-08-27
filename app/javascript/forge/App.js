import React from 'react'
import Layers from "./Layers"
import Map from './Map'
import Search from './Search'
import CensusSearch from "./CensusSearch";
import Building from './Building'

import { Provider } from 'react-redux'
import * as reducers from "./reducers"
import {forgeMiddleware} from './middlewares'
import { buildStore } from "./store";

console.log(reducers)
export default class App extends React.PureComponent {
    constructor(props) {
        super(props)
        this.mapRef = React.createRef()
        this.store = buildStore(reducers, forgeMiddleware)
        this.state = { sidebar: true }

        const year = this.store.getState().search.params.people
        if (year) {
            this.store.dispatch({type: 'FORGE_SET_YEAR', year: parseInt(year)})
        }
        this.store.dispatch({type: 'BUILDING_LOAD'})
    }

    render() {
        const { sidebar } = this.state
        return (
            <Provider store={this.store}>
                <div className={'map-wrap'}>
                    <Map />
                    <div id={'forge-right-col'} className={sidebar ? 'open' : 'closed'}>
                        <Layers />
                        <Search />
                        <CensusSearch />
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
