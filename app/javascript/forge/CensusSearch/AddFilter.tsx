import React from "react";

const AddFilter = ({ filters, addFilter }) => {
    if (!filters) return null;
    const handleChange = (e) => {
        const value = e.target.value;
        addFilter(value)
    }
    return (
        <select value='' onChange={handleChange} className="form-control">
            <option value={null}>Select a field to search</option>
            {Object.keys(filters).map(key => (
                filters[key].type && <option key={key} value={key}>{filters[key].label}</option>
            ))}
        </select>
    )
}

export default AddFilter;
