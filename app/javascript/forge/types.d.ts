declare namespace google {
    let maps: any;
}

interface IMap {
    overlayMapTypes: any;
}

interface SearchData {
    search: (term: string) => void;
}

interface SearchFilters {
    year: number;
    filters: any;
    setYear: (year: number) => void;
}

