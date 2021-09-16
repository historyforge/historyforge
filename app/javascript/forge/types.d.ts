declare var MarkerClusterer: any;

declare namespace google {
    let maps: any;
}

interface IMap {
    overlayMapTypes: any;
}

interface SearchData {
    search: (term: string) => void;
}

interface SearchParams {
    buildings?: keyable,
    s?: keyable,
    people?: number,
    peopleParams?: keyable
}

interface keyable {
    [key: string]: any
}

type MapProps = {
    buildings?: Array<keyable>,
    building?: any,
    params?: keyable,
    highlighted?: string,
    bubble?: keyable,
    layers?: Array<keyable>,
    deAddress?: () => {},
    address?: (id: number) => {},
    highlight?: (id: number) => {},
    select?: (id: number, params?: keyable) => {},
    center?: { lat: number, lng: number },
}

// interface SearchFilters {
//     year: number;
//     filters: any;
//     setYear: (year: number) => void;
// }
