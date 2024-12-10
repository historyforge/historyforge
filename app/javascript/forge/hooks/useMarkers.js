import {useEffect, useRef, useState} from "react";
import {generateMarkers, highlightMarker, unhighlightMarker} from "../mapFunctions";
import * as actions from "../actions";
import {useDispatch, useSelector} from "react-redux";

export function useMarkers(map, clusterMachine, bounds) {
  const dispatch = useDispatch();
  const { addressedAt, loadedAt, bubble, buildings } = useSelector(state => state.buildings);
  const searchParams = useSelector(state => state.search.params);

  // When buildings load, this updates a timestamp. We look for a change in this timestamp to signal that we need to render
  // new markers.
  const [prevLoadedAt, setPrevLoadedAt] = useState(null);

  // When you hover over a building, we request the address from the backend so we can show it in an infowindow. When this
  // request finishes, we update the timestamp. This signals us to show a new infowindow.
  const [prevAddressedAt, setPrevAddressedAt] = useState(null);

  // This ref holds all the markers that would ever show on the map given the search criteria. As the map bounds change,
  // we filter the markers that are visible on the map and pass them to the cluster machine.
  const markers = useRef(null);

  // This ref holds the currently selected building marker (the blue dot).
  const currentMarker = useRef(null);

  // When you hover over the building, you see its address in an InfoWindow. When you mouse off the window, we close it
  // one second later. It's jarring if we hide it immediately. We also close it before we show another one.
  const infoWindowTimeout = useRef(null);
  const infoWindow = useRef(null);

  const addMarkers = () => {
    if (!bounds || !markers.current) { return; }
    const desiredMarkers = Object.values(markers.current).filter(marker => bounds.contains(marker.position));
    clusterMachine.clearMarkers();
    clusterMachine.addMarkers(desiredMarkers);
  }

  useEffect(() => {
    if (!map) {
      return;
    }

    if (prevAddressedAt !== addressedAt) {
      setPrevAddressedAt(addressedAt);
      if (bubble) {
        if (infoWindow.current) infoWindow.current.close();
        infoWindow.current = new google.maps.InfoWindow({
          content: bubble.address
        })
        infoWindow.current.open({
          anchor: currentMarker.current,
          map
        });
      }
    }
  }, [bubble, addressedAt]);

  const showBuilding = (buildingId) => {
    dispatch(actions.select(buildingId, searchParams));
  }

  const highlight = (buildingId) => {
    highlightMarker(buildingId, markers.current);
    currentMarker.current = markers.current[buildingId]
    window.clearTimeout(infoWindowTimeout.current);
    if (infoWindow.current) {
      infoWindow.current.close();
    }
    dispatch(actions.address(buildingId));
  }

  const unHighlight = (buildingId) => {
    unhighlightMarker(parseInt(buildingId), markers.current);
    infoWindowTimeout.current = window.setTimeout(() => {
      dispatch(actions.deAddress());
      infoWindow.current.close();
    }, 1000);

  }

  useEffect(() => {
    if (!map || prevLoadedAt === loadedAt) { return; }
    const handlers = {
      onClick(building) {
        showBuilding(parseInt(building.id));
      },
      onMouseOver(building) {
        highlight(parseInt(building.id));
      },
      onMouseOut(building) {
        unHighlight(parseInt(building.id));
      }
    }
    markers.current = generateMarkers(buildings, handlers);
    setPrevLoadedAt(loadedAt);
    addMarkers();
  }, [loadedAt, prevLoadedAt]);

  useEffect(() => {
    if (map && bounds) {
      addMarkers();
    }
  }, [bounds]);
}
