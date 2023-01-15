import React, { useEffect, useState } from 'react'
import Layers from './Layers'
import Map from './Map'
import CensusSearch from './CensusSearch'
import Building from './Building'
import { forgeInit, reset, resetMap } from './actions'
import { useAppDispatch, useAppSelector } from './hooks'

const App = (): JSX.Element => {
  const [sidebarLeft, setSidebarLeft] = useState(false)
  const [sidebarRight, setSidebarRight] = useState(false);
  const dispatch = useAppDispatch();

  useEffect(() => {
    dispatch(forgeInit());
  }, [dispatch])

  const forgeActive = useAppSelector(state => state.layers.active || state.search.current);

  const resetForge = () => {
    dispatch(reset());
    dispatch(resetMap());
  }
  const closeSidebar = (e) => {
    e.stopPropagation();
    setSidebarRight(false);
    setSidebarLeft(false)
  }

  return (
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
    <div id="button-bar" className="btn-group">
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
      {forgeActive && !sidebarRight && !sidebarLeft && (
        <button type="button" className="btn btn-primary" onClick={resetForge}>Reset</button>
      )}
    </div>
      <Building />
    </div>
  )
}

export default App
