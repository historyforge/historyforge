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
      clusterMachine.clearLayers();
      const bounds = L.latLngBounds(
        focusOnPoints.map(point => L.latLng(point.lat, point.lon))
      );
      map.fitBounds(bounds);
      dispatch({ type: "FORGE_FOCUSED" });
      setPrevFocusOnPoints(focusOnPoints);
    }
  }, [map, focusOnPoints, focusOnPoints]);
}
