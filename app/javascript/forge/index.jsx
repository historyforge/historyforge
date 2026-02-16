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
        if (reactRoot) {
            reactRoot = null;
            store = null;
        }
        return;
    }

    if (reactRoot === forge) { return; }

    if (reactRoot && reactRoot !== forge) {
        ReactDOM.unmountComponentAtNode(reactRoot);
        reactRoot = null;
        store = null;
    }

    store = buildStore(reducers);
    reactRoot = forge;
    ReactDOM.render(<Provider store={store}><Forge /></Provider>, forge);
};

const cleanupForge = () => {
    if (reactRoot) {
        ReactDOM.unmountComponentAtNode(reactRoot);
        reactRoot = null;
        store = null;
    }
};

document.addEventListener('DOMContentLoaded', initializeForge);
document.addEventListener('turbo:load', initializeForge);
document.addEventListener('turbo:before-cache', cleanupForge);
