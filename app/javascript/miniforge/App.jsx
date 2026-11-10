// eslint-disable-next-line no-use-before-define
import React from 'react'
import { Layers } from './Layers'
import { Map } from './Map'
import { Buildings } from './Buildings'

const App = () => {
  return (
      <div className={'map-wrap'}>
        <Map />
        <div id={'miniforge-controls'}>
          <Layers />
          <Buildings />
        </div>
      </div>
  )
}

export default App
