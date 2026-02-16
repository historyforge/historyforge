import { useEffect, useRef, useState } from "react";
import L from "leaflet";
import { generateMarkers, highlightMarker, unhighlightMarker } from "../mapFunctions";
import * as actions from "../actions";
import { useDispatch, useSelector } from "react-redux";

export function useMarkers(map, clusterMachine) {
  const dispatch = useDispatch();
  const { addressedAt, loadedAt, bubble, buildings } = useSelector(state => state.buildings);
  const searchParams = useSelector(state => state.search.params);

  const [prevLoadedAt, setPrevLoadedAt] = useState(null);
  const [prevAddressedAt, setPrevAddressedAt] = useState(null);

  const markers = useRef(null);
  const currentMarker = useRef(null);
  const popupTimeout = useRef(null);
  const popup = useRef(null);

  useEffect(() => {
    if (!map) {
      return;
    }

    if (prevAddressedAt !== addressedAt) {
      setPrevAddressedAt(addressedAt);
      if (bubble && currentMarker.current) {
        if (popup.current) {
          map.closePopup(popup.current);
        }
        popup.current = L.popup()
          .setLatLng(currentMarker.current.getLatLng())
          .setContent(bubble.address)
          .openOn(map);
      }
    }
  }, [bubble, addressedAt]);

  const showBuilding = (buildingId) => {
    if (!buildingId || isNaN(buildingId)) {
      console.warn(`Invalid building ID: ${buildingId}`);
      return;
    }
    dispatch(actions.select(buildingId, searchParams));
  }

  const highlight = (buildingId) => {
    if (!buildingId || isNaN(buildingId)) {
      console.warn(`Invalid building ID for highlight: ${buildingId}`);
      return;
    }
    if (!markers.current) {
      console.warn('Markers not yet initialized');
      return;
    }
    highlightMarker(buildingId, markers.current);
    const marker = markers.current[buildingId];
    if (marker) {
      currentMarker.current = marker;
    }
    window.clearTimeout(popupTimeout.current);
    if (popup.current) {
      map.closePopup(popup.current);
    }
    dispatch(actions.address(buildingId));
  }

  const unHighlight = (buildingId) => {
    if (!buildingId || isNaN(buildingId)) {
      console.warn(`Invalid building ID for unhighlight: ${buildingId}`);
      return;
    }
    if (!markers.current) {
      console.warn('Markers not yet initialized');
      return;
    }
    unhighlightMarker(parseInt(buildingId), markers.current);
    popupTimeout.current = window.setTimeout(() => {
      dispatch(actions.deAddress());
      if (popup.current) {
        map.closePopup(popup.current);
      }
    }, 1000);
  }

  useEffect(() => {
    if (!map || !clusterMachine || prevLoadedAt === loadedAt) { return; }
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
    clusterMachine.clearLayers();
    if (markers.current) {
      clusterMachine.addLayers(Object.values(markers.current));
    }
  }, [loadedAt, prevLoadedAt]);
}
