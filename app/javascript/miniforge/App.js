import React from 'react'
import Layers from "./Layers"
import Map from './Map'
import Buildings from './Buildings'
import { Provider } from 'react-redux'
import * as reducers from "./reducers"
import {miniForgeMiddleware} from './middlewares'
import { buildStore } from "../forge/store";

export default class App extends React.PureComponent {
    mapRef = React.createRef()
    store = buildStore(reducers, miniForgeMiddleware)
    render() {
        return (
            <Provider store={this.store}>
                <div className={'map-wrap'}>
                    <Map />
                    <div id={'miniforge-controls'}>
                        <Layers />
                        <Buildings />
                    </div>
                </div>
            </Provider>
        )
    }

    get map() {
        return this.mapRef.current.state.map
    }
}
