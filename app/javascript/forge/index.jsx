import ReactDOM from "react-dom";
import Forge from "./App";
import React from "react";

import { Provider } from 'react-redux'
import * as reducers from './reducers'
import { buildStore } from './store'

google.maps.importLibrary("maps").then(() => {
    const forge = document.getElementById("forge");
    const store = buildStore(reducers);
    ReactDOM.render(<Provider store={store}><Forge /></Provider>, forge);
});
