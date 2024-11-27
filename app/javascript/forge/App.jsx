import React, {useEffect, useState} from 'react'
import Layers from './Layers'
import { Map } from './Map'
import CensusSearch from './CensusSearch'
import Building from './Building'
import {forgeInit, getBuildingsNearMe, reset, resetMap} from './actions'
import {useDispatch, useSelector} from 'react-redux'
import {Forges} from "./Forges";

const App = () => {
    const [sidebarLeft, setSidebarLeft] = useState(false)
    const [sidebarRight, setSidebarRight] = useState(false);
    const [forgePickerOpen, setForgePickerOpen] = useState(false);
    const hasForges = window.initialState.forges.forges.length > 1;
    const dispatch = useDispatch();

    useEffect(() => {
        dispatch(forgeInit());
    }, [dispatch])

    const forgeActive = useSelector(state => state.layers.active || state.search.current);
    const focusing = useSelector(state => state.layers.focusing || false);

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

    const centerOnMe = () => {
        dispatch({ type: "FORGE_FOCUSING"} )
        navigator.geolocation.getCurrentPosition(
            (position) => {
                const { coords } = position;
                dispatch(getBuildingsNearMe(coords))
            },
            (error) => {
                if (error.message.match(/denied/)) {
                    alert("Sorry but we can't show you what's nearby if you don't share your location.");
                } else {
                    alert(`Sorry but an error occurred while trying to get your location.: ${error.message}`)
                }
                console.error(error);
                dispatch({ type: "FORGE_FOCUSED"} )
            }
        );
    }

    return (
        <div className="map-wrap">
            <Map />
            <button id="near-me-button" onClick={centerOnMe} className="btn btn-primary">
                <i className="fa fa-bullseye" />
            </button>
            {focusing && <div id="focusing">Working</div>}
            {forgePickerOpen && (
                <div id="forge-left-col" className="open">
                    <button type="button" id="forge-sidebar-left-closer" className="btn btn-primary"
                            onClick={closeSidebar}>
                        <i className="fa fa-close"/>
                    </button>
                    <Forges />
                </div>
            )}
            {sidebarLeft && (
                <div id={'forge-left-col'} className="open">
                    <button type="button" id="forge-sidebar-left-closer" className="btn btn-primary"
                            onClick={closeSidebar}>
                        <i className="fa fa-close"/>
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
                        <i className="fa fa-close"/>
                    </button>
                    <CensusSearch />
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
            <Building />
        </div>
    )
}

export default App
