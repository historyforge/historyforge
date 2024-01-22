import React, {useEffect, useState} from 'react'
import Layers from './Layers'
import Map from './Map'
import CensusSearch from './CensusSearch'
import Building from './Building'
import {forgeInit, reset, resetMap} from './actions'
import {useAppDispatch, useAppSelector} from './hooks'
import {Forges} from "./Forges";

const App = (): React.ReactNode => {
    const [sidebarLeft, setSidebarLeft] = useState(false)
    const [sidebarRight, setSidebarRight] = useState(false);
    const [forgePickerOpen, setForgePickerOpen] = useState(false);
    const hasForges = window.initialState.forges.forges.length > 1;
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
        setSidebarLeft(false);
        setForgePickerOpen(false);
    }

    return (
        <div className="map-wrap">
            <Map/>
            {forgePickerOpen && (
                <div id="forge-left-col" className="open">
                    <button type="button" id="forge-sidebar-left-closer" className="btn btn-primary"
                            onClick={closeSidebar}>
                        <i className="fa fa-close"/>
                    </button>
                    <Forges/>
                </div>
            )}
            {sidebarLeft && (
                <div id={'forge-left-col'} className="open">
                    <button type="button" id="forge-sidebar-left-closer" className="btn btn-primary"
                            onClick={closeSidebar}>
                        <i className="fa fa-close"/>
                    </button>
                    <Layers/>
                </div>
            )}
            {sidebarRight && (
                <div id="forge-right-col" className="open">
                    <button type="button"
                            id="forge-sidebar-right-closer"
                            className="btn btn-primary"
                            onClick={closeSidebar}>
                        <i className="fa fa-close"/>
                    </button>
                    <CensusSearch/>
                </div>
            )}
            <div id="button-bar" className="btn-group">
                {!sidebarLeft && !sidebarRight && !forgePickerOpen && (
                    <>
                      {hasForges && (
                          <button type="button"
                                  id="forge-picker-toggle"
                                  className="btn btn-primary"
                                  onClick={(e) => {
                                    e.stopPropagation();
                                    setForgePickerOpen(true);
                                    setSidebarLeft(false);
                                    setSidebarRight(false)
                                  }}>
                            <i className="fa fa-car"/>
                          </button>
                      )}
                        <button type="button"
                                id="forge-sidebar-left-toggle"
                                className="btn btn-primary"
                                onClick={(e) => {
                                    e.stopPropagation();
                                    setSidebarLeft(true);
                                    setSidebarRight(false);
                                    setForgePickerOpen(false);
                                }}>
                            <i className="fa fa-map"/>
                        </button>
                        <button type="button"
                                id="forge-sidebar-right-toggle"
                                className="btn btn-primary"
                                onClick={(e) => {
                                    e.stopPropagation();
                                    setSidebarLeft(false);
                                    setSidebarRight(true)
                                    setForgePickerOpen(false);
                                }}>
                            <i className="fa fa-search"/>
                        </button>
                        {forgeActive && (
                            <button type="button" className="btn btn-primary" onClick={resetForge}>Reset</button>
                        )}
                    </>
                )}
            </div>
            <Building/>
        </div>
    )
}

export default App
