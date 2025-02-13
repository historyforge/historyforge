import {useEffect, useState} from "react";
import {useDispatch, useSelector} from "react-redux";

export function useMapTargeting(map, clusterMachine) {
  const dispatch = useDispatch();
  const focusOnPoints = useSelector(state => state.layers.focusOnPoints);
  const [prevFocusOnPoints, setPrevFocusOnPoints] = useState(null);

  useEffect(() => {
    if (!map) {
      return;
    }

    if (focusOnPoints && prevFocusOnPoints !== focusOnPoints) {
      // We don't want it to be fitting bounds and juggling thousands of markers, when the coming bounds
      // change will clear and re-add them anyway.
      clusterMachine.clearMarkers();
      const bounds = new google.maps.LatLngBounds();
      focusOnPoints.forEach(point => bounds.extend(new google.maps.LatLng(point.lat, point.lon)));
      map.fitBounds(bounds);
      dispatch({ type: "FORGE_FOCUSED"});
      setPrevFocusOnPoints(focusOnPoints);
    }
  }, [map, focusOnPoints, focusOnPoints]);

}