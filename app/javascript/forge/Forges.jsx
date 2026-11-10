import React from "react";
import { useSelector } from "react-redux";

export const Forges = () => {
  const forges = useSelector(state => state.forges.forges);
  return (
    <div>
      <h3>Jump to Localities</h3>
      <ul className="list-group">
        {forges.map(forge => <li key={forge.slug} className="list-group-item"><a href={`/${forge.slug}/forge`}>{forge.name}</a></li>)}
      </ul>
    </div>
  )
}