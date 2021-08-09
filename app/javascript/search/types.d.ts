type ScopeValue = string | number | string[] | number[];
type ChoiceValue = string | string[];
type Choices = Array<ChoiceValue>;
type AddInputFn = (input: HTMLElement) => void;

interface AttributeFilterConfig {
    type: string;
    label: string;
    scopes: object;
    append?: string;
    choices?: Choices;
    columns?: number
}

interface IAttributeFilter {
    render(): HTMLElement;
    renderLabel(): void;
    renderInput(): void;
    input: HTMLElement
    html: HTMLElement
    sentence: Array<string>
    config: AttributeFilterConfig
    scope: string
    scopeValue: ScopeValue
}

interface AdvancedSearchOptions {
    url: string;
    filters: Array<AttributeFilterConfig>;
}

interface IAdvancedSearch {
    currentFilters: Array<AttributeFilterConfig>;
    attributeFilters: Array<AttributeFilterConfig>;
    form: JQuery;
    initFormEvents(): void;
    showCurrentFilters(): void;
    showAddableFilters(): void;
}

