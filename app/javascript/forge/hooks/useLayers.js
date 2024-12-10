import {useEffect} from "react";
import {useSelector} from "react-redux";
import loadWMS from "../wms";

export function useLayers(map) {
  const layeredAt = useSelector(state => state.layers.layeredAt);
  const layers = useSelector(state => state.layers.layers);
  useEffect(() => {
    if (!map) { return; }
    addLayers(map, layers);
  }, [layeredAt]);
}

function addLayers(map, layers) {
  const selectedLayers = layers.filter(layer => layer.selected).sort((a, b) => a.year_depicted > b.year_depicted ? 1 : -1);
  const selectedLayerIds = selectedLayers.map(layer => layer.id);
  const currentLayers = map.overlayMapTypes.getArray();
  const currentLayerIds = currentLayers.map(layer => layer.name); // Name is actually an ID here...
  currentLayerIds.forEach((name, index) => {
    if (selectedLayerIds.indexOf(name) === -1) {
      map.overlayMapTypes.removeAt(index);
    }
  });
  selectedLayerIds.forEach((id, selectedIndex) => {
    if (currentLayerIds.indexOf(id) === -1) {
      loadWMS(map, selectedLayers[selectedIndex], selectedIndex);
    }
  });
}
