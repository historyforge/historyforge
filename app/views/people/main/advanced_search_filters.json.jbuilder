# frozen_string_literal: true

json.filters do
  json.name do
    json.type 'text'
    json.label 'Name'
    json.scopes do
      json.name_fuzzy_matches 'fuzzy matches'
      json.name_cont 'contains exactly'
    end
    json.sortable 'name'
  end

  AttributeBuilder.text   json, :names_first_name
  AttributeBuilder.text   json, :names_middle_name
  AttributeBuilder.text   json, :names_last_name

  AttributeBuilder.enumeration json, Person, :sex
  AttributeBuilder.enumeration json, Person, :race

  AttributeBuilder.text json, :pob

  AttributeBuilder.text json, :description

end
