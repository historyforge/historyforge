import ReactDOM from "react-dom";
import Forge from "./App";
import React from "react";

document.addEventListener('DOMContentLoaded', () => {
    const forge = document.getElementById('forge')
    if (forge) ReactDOM.render(<Forge />, forge)
})
