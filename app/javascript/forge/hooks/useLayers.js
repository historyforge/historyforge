import { useEffect, useRef } from "react";
import { useSelector } from "react-redux";
import loadWMS from "../wms";

export function useLayers(map) {
  const layeredAt = useSelector(state => state.layers.layeredAt);
  const opacityAt = useSelector(state => state.layers.opacityAt);
  const layers = useSelector(state => state.layers.layers);
  const activeLayers = useRef({});

  useEffect(() => {
    if (!map) { return; }
    syncLayers(map, layers, activeLayers);
  }, [layeredAt]);

  useEffect(() => {
    if (!map) { return; }
    syncOpacity(layers, activeLayers);
  }, [opacityAt]);
}

function syncLayers(map, layers, activeLayers) {
  const selectedLayers = layers
    .filter(layer => layer.selected)
    .sort((a, b) => a.year_depicted > b.year_depicted ? 1 : -1);
  const selectedLayerIds = selectedLayers.map(layer => layer.id);

  Object.keys(activeLayers.current).forEach(id => {
    if (selectedLayerIds.indexOf(id) === -1 && selectedLayerIds.indexOf(parseInt(id)) === -1) {
      map.removeLayer(activeLayers.current[id]);
      delete activeLayers.current[id];
    }
  });

  selectedLayers.forEach(layer => {
    if (!activeLayers.current[layer.id]) {
      const wmsLayer = loadWMS(map, layer);
      wmsLayer.addTo(map);
      activeLayers.current[layer.id] = wmsLayer;
    }
  });
}

function syncOpacity(layers, activeLayers) {
  Object.entries(activeLayers.current).forEach(([id, leafletLayer]) => {
    const layerData = layers.find(l => String(l.id) === String(id));
    if (layerData && typeof layerData.opacity === 'number') {
      leafletLayer.setOpacity(layerData.opacity / 100);
    } else if (layerData) {
      leafletLayer.setOpacity(1);
    }
  });
}
