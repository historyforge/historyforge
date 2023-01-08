import React from 'react'
import { connect } from 'react-redux'
import { Modal, ModalHeader, ModalBody, Row, Col } from 'reactstrap'
import Residents from './Residents'
import Details from './Details'

class Building extends React.PureComponent {
    state = { visible: false, building_id: null }
    close() {
      this.setState({ visible: false }, () => {
        this.props.deselect(this.state.building_id)
      })
    }

    static getDerivedStateFromProps(props, state) {
      if (props.id) {
        if (!state.building_id || (props.id !== state.building_id)) {
          state.building_id = props.id
          state.visible = true
        }
      } else {
        state.building_id = null
        state.visible = false
      }
      return state
    }

    render() {
      const { visible } = this.state
      return (
            <Modal size={this.hasResidents() ? 'xl' : 'md'} isOpen={visible}>
                <ModalHeader toggle={this.close.bind(this)}>
                    Building Details
                </ModalHeader>
                <ModalBody>
                    {this.props.id && this.renderBuilding()}
                </ModalBody>
            </Modal>
      )
    }

    renderBuilding() {
      const building = this.props

      if (this.hasResidents()) {
        return (
                <div id="building-details">
                    <Row>
                        <Col sm={12} lg={5}>
                            <Details {...building} />
                        </Col>
                        <Col sm={12} lg={7}>
                            <Residents buildingId={building.id} residents={building.census_records} years={this.props.years} />
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

    hasResidents() {
      return this.props.census_records &&
            Object.keys(this.props.census_records).length
    }
}

const mapStateToProps = state => {
  if (state.buildings.building) {
    return { ...state.buildings.building, years: state.search.years }
  } else {
    return {}
  }
}

const actions = {
  deselect: (id) => ({ type: 'BUILDING_DESELECT', id })
}

const Component = connect(mapStateToProps, actions)(Building)

export default Component
