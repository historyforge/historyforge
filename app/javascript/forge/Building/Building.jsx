import React, { useState, useCallback, useEffect, useMemo} from 'react'
import {useDispatch} from 'react-redux';
import { Modal, ModalHeader, ModalBody, Row, Col } from 'reactstrap'
import {Residents} from './Residents'
import {Details} from './Details'

export const BuildingModal = ({ building, years }) => {
  const dispatch = useDispatch();
  const [visible, setVisible] = useState(false);
  const [buildingId, setBuildingId] = useState(null);

  useEffect(() => {
    if (building) {
      if (!buildingId || building.id !== buildingId) {
        setBuildingId(building.id);
        setVisible(true);
      }
    } else {
      setBuildingId(null);
      setVisible(false);
    }
  }, [building, buildingId]);

  const residents = building && building.census_records;
  const hasResidents = useMemo(() => residents && !!Object.keys(building.census_records).length, [building]);

  const close = useCallback(() => {
    setVisible(false);
    dispatch({ type: "BUILDING_DESELECT", id: buildingId });
  }, [buildingId]);

  return (
    <Modal size={hasResidents ? 'xl' : 'md'} isOpen={visible}>
      <ModalHeader toggle={close}>
        Building Details
      </ModalHeader>
      <ModalBody>
        {building ? <Building building={building} residents={residents} hasResidents={hasResidents} years={years} /> : null}
      </ModalBody>
    </Modal>
  )
}

const Building = ({ building, years, residents, hasResidents }) => {
  if (hasResidents) {
    return (
      <div id="building-details">
        <Row>
          <Col sm={12} lg={5}>
            <Details {...building} />
          </Col>
          <Col sm={12} lg={7}>
            <Residents buildingId={building.id} residents={residents} years={years} />
          </Col>
        </Row>
      </div>
    )
  }

  return (
    <div id="building-details">
      <Details {...building} />
    </div>
  )
}
