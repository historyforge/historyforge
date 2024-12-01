import {useEffect} from "react";
import { useSelector } from "react-redux";

export function addOpacity(map, layers) {
}

export function useOpacity(map) {
  const opacityAt = useSelector(state => state.layers.opacityAt);
  const layers = useSelector(state => state.layers.layers);

  useEffect(() => {
    if (map) {
      const currentLayers = map.overlayMapTypes.getArray();

      currentLayers.forEach(layer => {
        const opacity = layers.find(l => l.id === layer.name).opacity
        if (typeof (opacity) === 'number') {
          layer.setOpacity(opacity / 100)
        } else {
          layer.setOpacity(1)
        }
      });
    }
  }, [opacityAt]);

}