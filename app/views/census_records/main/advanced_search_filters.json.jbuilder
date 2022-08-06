# frozen_string_literal: true

json.filters do
  CensusFiltersGenerator.generate(json, census_form_renderer)
end
