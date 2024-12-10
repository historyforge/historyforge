import React from 'react'

const YearButtons = ({ years, setYear, year }) => {
    if (!years) return null;
    const handleChange = (e) => {
        const value = e.target.value;
        setYear(value)
    }
    return (
        <select value={year} onChange={handleChange} className="form-control mb-1">
            <option value={null}>Select a year to search</option>
            {years.map(key => (
                <option key={key} value={key}>{key}</option>
            ))}
        </select>
    )
}

export default YearButtons
