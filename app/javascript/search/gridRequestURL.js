export function gridRequestURL(location, { startRow, endRow, sortModel }) {
  const url = new URL(location)
  url.searchParams.set('from', startRow)
  url.searchParams.set('to', endRow)
  for (const key of [...url.searchParams.keys()]) {
    if (key.startsWith('sort[')) url.searchParams.delete(key)
  }
  sortModel.forEach(({ colId, sort }, index) => {
    url.searchParams.set(`sort[${index}][colId]`, colId)
    url.searchParams.set(`sort[${index}][sort]`, sort)
  })
  return url
}
