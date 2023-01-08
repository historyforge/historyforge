import ReactDOM from "react-dom";
import Forge from "./App";
import React from "react";

import { Provider } from 'react-redux'
import * as reducers from './reducers'
import { buildStore } from './store'

const store = buildStore(reducers);
document.addEventListener('DOMContentLoaded', () => {
    const forge = document.getElementById('forge')
    if (forge) ReactDOM.render(<Provider store={store}><Forge /></Provider>, forge)
})
