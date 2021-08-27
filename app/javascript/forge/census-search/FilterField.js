import BooleanField from "./census-search/BooleanField";
import ListField from "./census-search/ListField";
import NumberField from "./census-search/NumberField";
import TextField from "./census-search/TextField";

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
