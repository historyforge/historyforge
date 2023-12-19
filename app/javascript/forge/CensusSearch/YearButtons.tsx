// import { ButtonGroup } from 'reactstrap'
import React from 'react'

// const YearButton = ({ censusYear, displayYear, onClick }) => (
//     <button type="button"
//             key={censusYear}
//             className={`btn btn-${censusYear === displayYear ? 'primary' : 'light'}`}
//             onClick={onClick}>
//         {censusYear}
//     </button>
// )

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

// const YearButtons = ({ years, setYear, year }) => (
//     <ButtonGroup className="btn-group btn-block">
//         {years.map(censusYear =>
//             <YearButton key={censusYear}
//                               censusYear={censusYear}
//                               displayYear={year}
//                               onClick={ () => setYear(censusYear) }
//             />
//         )}
//     </ButtonGroup>
// )

export default YearButtons
