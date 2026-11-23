import { useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import L from "leaflet";

export function useMapTargeting(map, clusterMachine) {
  const dispatch = useDispatch();
  const place = useSelector(state => state.buildings.focusedPlace);
  useEffect(() => {
    if (!map || !place || place.latitude == null || place.longitude == null) return;
    const lat = Number(place.latitude), lng = Number(place.longitude);
    if (!Number.isFinite(lat) || !Number.isFinite(lng)) return;
    const location = L.latLng(lat, lng);
    const ring = L.circleMarker(location, { radius: 15, color: '#e6b651', weight: 4, fillOpacity: 0, interactive: false }).addTo(map);
    const centerPlace = () => {
      const offset = window.innerWidth >= 1800 ? map.getSize().x / 4 : 0;
      const center = map.unproject(map.project(location).add(L.point(offset, 0)));
      map.panTo(center, { animate: !window.matchMedia('(prefers-reduced-motion: reduce)').matches });
    };
    centerPlace();
    map.on('resize', centerPlace);
    return () => { map.off('resize', centerPlace); ring.remove(); };
  }, [map, place]);
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
