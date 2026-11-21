export const buildings = function(state = {}, action) {
  if (action.type === 'FORGE_PHOTOS') return { ...state, photoMode: action.enabled, building: null, photoBuildingId: null }
  if (action.type === 'PHOTO_BUILDING_SELECTED') return { ...state, photoBuildingId: action.id }
  if (action.type === 'PHOTO_BUILDING_DESELECT') return { ...state, photoBuildingId: null }
  if (action.type === 'BUILDINGS_LOADING') return { ...state, loading: true, error: null }
  if (action.type === 'BUILDINGS_FAILED') return { ...state, loading: false, error: 'Unable to load the map. Please try again.' }
  if (action.type === 'BUILDING_HIGHLIGHT') {
    return {
      ...state,
      highlighted: state.highlighted === action.id ? null : action.id
    }
  }

  if (action.type === 'BUILDING_ADDRESS_LOADED') {
    return { ...state, bubble: action.address, addressedAt: new Date().getTime() }
  }

  if (action.type === 'BUILDING_ADDRESS_REMOVE') {
    return { ...state, bubble: null, addressedAt: new Date().getTime() }
  }

  if (action.type === 'BUILDING_LOADED') {
    const { buildings } = action
    const info = action.meta ? action.meta.info : `Found ${buildings.length} results.`
    return { ...state, building: null, photoBuildingId: null, loading: false, resultPhotoMode: !!action.photoMode, highlighted: null, buildings: buildings || [], message: info, loadedAt: new Date().getTime() }
  }

  if (action.type === 'BUILDING_SELECTED') {
    const { building } = action
    return { ...state, building, highlighted: null } //, highlighted: action.building.id }
  }

  if (action.type === 'BUILDING_DESELECT') {
    return { ...state, building: null, highlighted: null }
  }

  return state
}
