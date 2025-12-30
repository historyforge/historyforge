import ReactDOM from "react-dom";
import Forge from "./App";
import React from "react";
import { Provider } from 'react-redux'
import * as reducers from './reducers'
import { buildStore } from './store'

let reactRoot = null;
let store = null;

const initializeForge = () => {
    const forge = document.getElementById("forge");
    if (!forge) {
        // Reset if element doesn't exist (navigated away)
        if (reactRoot) {
            reactRoot = null;
            store = null;
        }
        return;
    }

    // If already mounted to this element, skip initialization
    if (reactRoot === forge) { return; }

    // Clean up previous mount if element changed
    if (reactRoot && reactRoot !== forge) {
        ReactDOM.unmountComponentAtNode(reactRoot);
        reactRoot = null;
        store = null;
    }

    if (typeof google === 'undefined' || !google.maps || !google.maps.importLibrary) {
        // Google Maps API not loaded (e.g., bot request) - skip initialization
        return;
    }

    google.maps.importLibrary("maps").then(() => {
        if (!reactRoot) {
            store = buildStore(reducers);
            reactRoot = forge;
            ReactDOM.render(<Provider store={store}><Forge /></Provider>, forge);
        }
    });
};

const cleanupForge = () => {
    if (reactRoot) {
        ReactDOM.unmountComponentAtNode(reactRoot);
        reactRoot = null;
        store = null;
    }
};

// Handle both initial page load and Turbo navigation
document.addEventListener('DOMContentLoaded', initializeForge);
document.addEventListener('turbo:load', initializeForge);
document.addEventListener('turbo:before-cache', cleanupForge);
