import React from 'react'
import { connect } from 'react-redux'
import { FormGroup, Label, Input } from 'reactstrap'

class Layer extends React.PureComponent {
  render() {
    const selected = this.props.selected || false
    const opacity = this.props.opacity === undefined ? 100 : this.props.opacity
    const { id, name, toggle, setOpacity } = this.props

    return (
            <div className="layer">
                <FormGroup check>
                    <Label check>
                        <Input type="checkbox" className="form-check-input" checked={selected} onChange={toggle} />
                        {name}
                    </Label>
                    {selected && <input type="range"
                                        min={0}
                                        max={100}
                                        value={opacity}
                                        onChange={(e) => setOpacity(id, e.target.value)} />}
                </FormGroup>
            </div>
    )
  }
}

class Layers extends React.PureComponent {
  render() {
    const { layers } = this.props
    if (!layers || !layers.length) return null

    const { toggle, setOpacity } = this.props
    return (
            <div>
                <h3>Map Layers</h3>
                {layers.map(layer => <Layer key={layer.id} {...layer} toggle={() => toggle(layer.id)} setOpacity={setOpacity} />)}
            </div>
    )
  }
}

const mapStateToProps = state => {
  return { ...state.layers }
}

const actions = {
  toggle: (id) => ({ type: 'LAYER_TOGGLE', id }),
  setOpacity: (id, opacity) => ({ type: 'LAYER_OPACITY', id, opacity })
}

const Component = connect(mapStateToProps, actions)(Layers)

export default Component
