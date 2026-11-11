export default function isValuelessPredicate(predicate) {
  return /_(?:null|blank|present)$/.test(predicate)
}
