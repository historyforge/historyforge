import { Modal, ModalBody, ModalFooter, ModalHeader } from 'reactstrap'
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
    <Modal isOpen={!!open}>
        <ModalHeader toggle={close}>
            Search on &ldquo;{open && filters[open].label}&rdquo;
        </ModalHeader>
        <ModalBody>
            {open && <FilterField {...current[open]} config={filters[open]} handleChange={setFilter} />}
        </ModalBody>
        <ModalFooter>
            <button className="btn btn-primary" type="button" onClick={search}>Search</button>
        </ModalFooter>
    </Modal>
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
