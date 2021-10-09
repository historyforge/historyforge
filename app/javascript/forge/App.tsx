import React, { useEffect, useState } from 'react'
import Layers from './Layers'
import Map from './Map'
// import Search from './Search'
import CensusSearch from './CensusSearch'
import Building from './Building'

import { Provider } from 'react-redux'
import * as reducers from './reducers'
import { buildStore } from './store'
import { setYear } from './actions'

const App = (): JSX.Element => {
  const [sidebar, setSidebar] = useState(true)
  const [store, setStore] = useState(null)
  store || setStore(buildStore(reducers))

  useEffect(() => {
    store.dispatch(setYear())
  })

  return (
    <Provider store={store}>
      <div className={'map-wrap'}>
        <Map />
        <div id={'forge-right-col'} className={sidebar ? 'open' : 'closed'}>
          <Layers />
          {/* <Search /> */}
          <CensusSearch />
        </div>
        <button type="button"
                id="forge-sidebar-toggle"
                className="btn btn-primary"
                onClick={() => setSidebar(!sidebar)}>
          <i className={`fa fa-chevron-${sidebar ? 'left' : 'right'}`} />
        </button>
        <Building />
      </div>
    </Provider>
  )
}

export default App
