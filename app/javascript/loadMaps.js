export function loadMaps() {
  return import(document.querySelector('meta[name="maps-url"]').content)
}
