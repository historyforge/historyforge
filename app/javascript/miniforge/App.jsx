// eslint-disable-next-line no-use-before-define
import React, { useState } from 'react'
import { Layers } from './Layers'
import { Map } from './Map'
import { Buildings } from './Buildings'
import { Provider } from 'react-redux'
import * as reducers from './reducers'
import { buildStore } from '../forge/store'

const App = () => {
  const [store, setStore] = useState(null)
  store || setStore(buildStore(reducers))

  return (
    <Provider store={store}>
      <div className={'map-wrap'}>
        <Map />
        <div id={'miniforge-controls'}>
          <Layers />
          <Buildings />
        </div>
      </div>
    </Provider>
  )
}

export default App
