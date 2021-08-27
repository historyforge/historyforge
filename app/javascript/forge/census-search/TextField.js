import BasicField from "./BasicField";
import React from "react";

export default function TextField(props) {
    const { field, predicate, criteria, config: { scopes }, handleChange } = props
    return <BasicField type={'text'}
                       field={field}
                       predicate={predicate}
                       criteria={criteria}
                       scopes={scopes}
                       handleChange={handleChange} />
}
