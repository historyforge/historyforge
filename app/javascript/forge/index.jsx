import ReactDOM from "react-dom";
import Forge from "./App";
import React from "react";
import { Provider } from 'react-redux'
import * as reducers from './reducers'
import { buildStore } from './store'

document.addEventListener('DOMContentLoaded', () => {
    const forge = document.getElementById("forge");
    if (!forge) { return; }
    google.maps.importLibrary("maps").then(() => {
        const store = buildStore(reducers);
        ReactDOM.render(<Provider store={store}><Forge /></Provider>, forge);
    });
});
