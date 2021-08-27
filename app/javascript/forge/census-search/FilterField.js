import React from 'react'
import BooleanField from "./BooleanField";
import ListField from "./ListField";
import NumberField from "./NumberField";
import TextField from "./TextField";

export default function FilterField(props) {
    const { config: { type } } = props
    switch(type) {
        case 'boolean': return <BooleanField {...props} />
        case 'checkboxes': return <ListField {...props} />
        case 'number': return <NumberField {...props} />
        case 'text': return <TextField {...props} />
        default: return null
    }
}
