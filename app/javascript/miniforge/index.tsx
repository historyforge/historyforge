import ReactDOM from "react-dom";
import MiniForge from "./App";
import React from "react";
import {buildStore} from "../forge/store";
import * as reducers from "../forge/reducers";
import {Provider} from "react-redux";
import Forge from "../forge/App";

google.maps.importLibrary("maps").then(() => {
    const miniforge = document.getElementById('miniforge')
    if (miniforge) ReactDOM.render(<MiniForge />, miniforge)
});
