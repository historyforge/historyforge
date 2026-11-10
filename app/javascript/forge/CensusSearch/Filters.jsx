import ForgeModal from '../ForgeModal'
import FilterListItem from './FilterListItem'
import React from 'react'
import FilterField from './FilterField'

const CurrentFilters = ({ current, filters, setOpen, remove }) => (
    <div className="list-group">
        {Object.keys(current).map(key => (
            <FilterListItem key={key}
                            {...current[key]}
                            config={filters[key]}
                            setOpen={() => setOpen(key)}
                            remove={(e) => { e.stopPropagation(); remove(key) }}
            />
        ))}
    </div>
)

const FilterModal = ({ filters, current, close, open, search, setFilter }) => (
    <ForgeModal open={!!open}
                onClose={close}
                title={open && `Search on “${filters[open].label}”`}
                footer={<button className="btn btn-primary" type="button" onClick={search}>Search</button>}>
        {open && <FilterField {...current[open]} config={filters[open]} handleChange={setFilter} />}
    </ForgeModal>
)

const Filters = (props) => (
    props.current ? (
        <>
            <CurrentFilters {...props} />
            <FilterModal {...props} />
        </>
    ) : null
  )

export default Filters
