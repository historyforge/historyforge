import ReactDOM from "react-dom";
import MiniForge from "./App";
import React from "react";

document.addEventListener('DOMContentLoaded', () => {
    const miniforge = document.getElementById('miniforge')
    if (miniforge) ReactDOM.render(<MiniForge />, miniforge)
})
