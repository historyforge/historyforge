import React, { useEffect, useState } from 'react'
import Layers from './Layers'
import Map from './Map'
import CensusSearch from './CensusSearch'
import Building from './Building'

import { Provider } from 'react-redux'
import * as reducers from './reducers'
import { buildStore } from './store'
import { setYear } from './actions'

const App = (): JSX.Element => {
  const [sidebarLeft, setSidebarLeft] = useState(false)
  const [sidebarRight, setSidebarRight] = useState(false);
  const [store, setStore] = useState(null)
  store || setStore(buildStore(reducers))

  useEffect(() => {
    store.dispatch(setYear())
  })

  const closeSidebar = (e) => {
    e.stopPropagation(); 
    setSidebarRight(false); 
    setSidebarLeft(false)
  }

  return (
    <Provider store={store}>
      <div className="map-wrap">
        <Map />
        {sidebarLeft && (
        <div id={'forge-left-col'} className="open">
          <button type="button" id="forge-sidebar-left-closer" className="btn btn-primary"
            onClick={closeSidebar}>
            <i className="fa fa-close" />
          </button>
          <Layers />
        </div>
      )}
        {sidebarRight && (
        <div id="forge-right-col" className="open">
          <button type="button"
                  id="forge-sidebar-right-closer"
                  className="btn btn-primary"
                  onClick={closeSidebar}>
            <i className="fa fa-close" />
          </button>
          <CensusSearch />
        </div>
      )}
        {!sidebarLeft && !sidebarRight && (
          <button type="button"
            id="forge-sidebar-left-toggle"
            className="btn btn-primary"
            onClick={(e) => { e.stopPropagation(); setSidebarLeft(true); setSidebarRight(false)}}>
            <i className="fa fa-map" />
          </button>
        )}
        {!sidebarRight && !sidebarLeft && (
          <button type="button"
            id="forge-sidebar-right-toggle"
            className="btn btn-primary"
            onClick={(e) => { e.stopPropagation(); setSidebarLeft(false); setSidebarRight(true)}}>
            <i className="fa fa-search" />
          </button>
        )}
        <Building />
      </div>
    </Provider>
  )
}

export default App
