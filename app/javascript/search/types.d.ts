export type ScopeValue = string | number | string[] | number[];
export type ChoiceValue = string | string[];
export type Choices = Array<ChoiceValue>;
export type AddInputFn = (input: HTMLElement) => void;

export interface AttributeFilterConfig {
    type: string;
    label: string;
    scopes: object;
    append?: string;
    choices?: Choices;
    columns?: number
}

export interface IAttributeFilter {
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

export interface AdvancedSearchOptions {
    url: string;
    filters: Array<AttributeFilterConfig>;
}

export interface IAdvancedSearch {
    currentFilters: Array<AttributeFilterConfig>;
    attributeFilters: Array<AttributeFilterConfig>;
    form: JQuery;
    initFormEvents(): void;
    showCurrentFilters(): void;
    showAddableFilters(): void;
}
