import ReactDOM from "react-dom";
import MiniForge from "./App";
import { exitMapFullscreen } from './fullscreenControl';
import React from "react";
import { Provider } from 'react-redux'
import * as reducers from './reducers'
import { buildStore } from '../forge/store'

let reactRoot = null;

export const initializeMiniForge = () => {
    const miniforge = document.getElementById('miniforge')
    if (!miniforge) {
        if (reactRoot) {
            reactRoot = null;
        }
        return;
    }

    if (reactRoot === miniforge) { return; }

    if (reactRoot && reactRoot !== miniforge) {
        ReactDOM.unmountComponentAtNode(reactRoot);
        reactRoot = null;
    }

    reactRoot = miniforge;
    const store = buildStore(reducers, JSON.parse(miniforge.dataset.initialState))
    ReactDOM.render(<Provider store={store}><MiniForge /></Provider>, miniforge)
};

const cleanupMiniForge = () => {
    exitMapFullscreen();
    if (reactRoot) {
        ReactDOM.unmountComponentAtNode(reactRoot);
        reactRoot = null;
    }
};

document.addEventListener('turbo:before-cache', cleanupMiniForge);
document.addEventListener('turbo:before-render', cleanupMiniForge);
