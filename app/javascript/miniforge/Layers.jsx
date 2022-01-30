import React from 'react'
import { connect } from 'react-redux'

class Layers extends React.PureComponent {
  render() {
    const { layers, layer, opacity, setOpacity } = this.props
    if (!layers || !layers.length) return null

    return (
          <div>
              <input type="range"
                     min={0}
                     max={100}
                     value={opacity > -1 ? opacity : 100}
                     onChange={(e) => setOpacity(e.target.value)} />
              <select className="form-control" value={layer?.id} onChange={this.handleChange.bind(this)}>
                <option value={null}>No historic map</option>
                {layers.map(l => <option key={l.id} value={l.id}>{l.name}</option>)}
              </select>
          </div>
    )
  }

  handleChange(event) {
    const value = parseInt(event.currentTarget.value)
    const layer = this.props.layers.find(l => l.id === value)
    this.props.toggle(layer?.id)
  }
}

const mapStateToProps = state => {
  return { ...state.layers }
}

const actions = {
  toggle: (id) => ({ type: 'LAYER_TOGGLE', id }),
  setOpacity: (opacity) => ({ type: 'LAYER_OPACITY', opacity })
}

const Component = connect(mapStateToProps, actions)(Layers)

export default Component
