import ReactDOM from "react-dom";
import MiniForge from "./App";
import React from "react";

let reactRoot = null;

const initializeMiniForge = () => {
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
    ReactDOM.render(<MiniForge />, miniforge)
};

const cleanupMiniForge = () => {
    if (reactRoot) {
        ReactDOM.unmountComponentAtNode(reactRoot);
        reactRoot = null;
    }
};

document.addEventListener('DOMContentLoaded', initializeMiniForge);
document.addEventListener('turbo:load', initializeMiniForge);
document.addEventListener('turbo:before-cache', cleanupMiniForge);
