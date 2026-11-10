import ReactDOM from "react-dom";
import Forge from "./App";
import React from "react";
import { Provider } from 'react-redux'
import * as reducers from './reducers'
import { buildStore } from './store'

let reactRoot = null;

export const initializeForge = () => {
    const forge = document.getElementById("forge");
    if (!forge) {
        if (reactRoot) {
            reactRoot = null;
        }
        return;
    }

    if (reactRoot === forge) { return; }

    if (reactRoot && reactRoot !== forge) {
        ReactDOM.unmountComponentAtNode(reactRoot);
        reactRoot = null;
    }

    const store = buildStore(reducers, JSON.parse(forge.dataset.initialState));
    reactRoot = forge;
    ReactDOM.render(<Provider store={store}><Forge /></Provider>, forge);
};

const cleanupForge = () => {
    if (reactRoot) {
        ReactDOM.unmountComponentAtNode(reactRoot);
        reactRoot = null;
    }
};

document.addEventListener('turbo:before-cache', cleanupForge);
document.addEventListener('turbo:before-render', cleanupForge);
