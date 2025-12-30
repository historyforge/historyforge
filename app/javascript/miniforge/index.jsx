import ReactDOM from "react-dom";
import MiniForge from "./App";
import React from "react";
import { buildStore } from "../forge/store";
import * as reducers from "../forge/reducers";
import { Provider } from "react-redux";
import Forge from "../forge/App";

let reactRoot = null;

const initializeMiniForge = () => {
    const miniforge = document.getElementById('miniforge')
    if (!miniforge) {
        // Reset if element doesn't exist (navigated away)
        if (reactRoot) {
            reactRoot = null;
        }
        return;
    }

    // If already mounted to this element, skip initialization
    if (reactRoot === miniforge) { return; }

    // Clean up previous mount if element changed
    if (reactRoot && reactRoot !== miniforge) {
        ReactDOM.unmountComponentAtNode(reactRoot);
        reactRoot = null;
    }

    if (typeof google === 'undefined' || !google.maps || !google.maps.importLibrary) {
        // Google Maps API not loaded (e.g., bot request) - skip initialization
        return;
    }

    google.maps.importLibrary("maps").then(() => {
        if (miniforge && !reactRoot) {
            reactRoot = miniforge;
            ReactDOM.render(<MiniForge />, miniforge)
        }
    });
};

const cleanupMiniForge = () => {
    if (reactRoot) {
        ReactDOM.unmountComponentAtNode(reactRoot);
        reactRoot = null;
    }
};

// Handle both initial page load and Turbo navigation
document.addEventListener('DOMContentLoaded', initializeMiniForge);
document.addEventListener('turbo:load', initializeMiniForge);
document.addEventListener('turbo:before-cache', cleanupMiniForge);

