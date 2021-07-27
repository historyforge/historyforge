const buildParams = function(search) {
    const params = { s: {} }
    if (search.buildings) {
        params.s = search.s
    }
    if (search.people) {
        params.people = search.people
        params.peopleParams = search.s
    }
    params.s.lat_not_null = 1
    return params
}

export default buildParams;
