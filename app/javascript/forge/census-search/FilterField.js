import React from 'react'
import BasicField from "./BasicField";
import BooleanField from "./BooleanField";
import ListField from "./ListField";

export default function FilterField(props) {
    const { config: { type } } = props
    switch(type) {
        case 'boolean': return <BooleanField {...props} />
        case 'checkboxes': return <ListField {...props} />
        case 'number': return <BasicField type="number" {...props} />
        case 'text': return <BasicField type="text" {...props} />
        default: return null
    }
}
