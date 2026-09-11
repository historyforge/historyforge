import { useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import L from "leaflet";

export function useMapTargeting(map, clusterMachine) {
  const dispatch = useDispatch();
  const focusOnPoints = useSelector(state => state.layers.focusOnPoints);
  const [prevFocusOnPoints, setPrevFocusOnPoints] = useState(null);

  useEffect(() => {
    if (!map) {
      return;
    }

    if (focusOnPoints && prevFocusOnPoints !== focusOnPoints) {
      const bounds = L.latLngBounds(
        focusOnPoints.map(point => L.latLng(point.lat, point.lon))
      );
      if (bounds.isValid()) {
        // Avoid updating thousands of markers during a long camera move.
        // Detach the group without discarding its markers, then restore it
        // synchronously: an unchanged view may never emit moveend.
        const restoreMarkers = clusterMachine && map.hasLayer(clusterMachine);
        if (restoreMarkers) map.removeLayer(clusterMachine);
        try {
          map.fitBounds(bounds, { animate: false });
        } finally {
          if (restoreMarkers) map.addLayer(clusterMachine);
        }
      }
      dispatch({ type: "FORGE_FOCUSED" });
      setPrevFocusOnPoints(focusOnPoints);
    }
  }, [map, clusterMachine, focusOnPoints, prevFocusOnPoints, dispatch]);
}
