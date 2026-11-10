import ForgeModal from '../ForgeModal'
import React, { useState, useCallback, useEffect, useMemo} from 'react'
import {useDispatch} from 'react-redux';
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
    <ForgeModal open={visible} onClose={close} title="Building Details" size={hasResidents ? 'xl' : undefined}>
      {building ? <Building building={building} residents={residents} hasResidents={hasResidents} years={years} /> : null}
    </ForgeModal>
  )
}

const Building = ({ building, years, residents, hasResidents }) => {
  if (hasResidents) {
    return (
      <div id="building-details">
        <div className="row">
          <div className="col-sm-12 col-lg-5">
            <Details {...building} />
          </div>
          <div className="col-sm-12 col-lg-7">
            <Residents buildingId={building.id} residents={residents} years={years} />
          </div>
        </div>
      </div>
    )
  }

  return (
    <div id="building-details">
      <Details {...building} />
    </div>
  )
}
