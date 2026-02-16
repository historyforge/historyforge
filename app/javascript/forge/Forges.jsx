import React from "react";

export const Forges = () => {
  const {forges} = window.initialState.forges;
  return (
    <div>
      <h3>Jump to Localities</h3>
      <ul className="list-group">
        {forges.map(forge => <li key={forge.slug} className="list-group-item"><a href={`/${forge.slug}/forge`}>{forge.name}</a></li>)}
      </ul>
    </div>
  )
}