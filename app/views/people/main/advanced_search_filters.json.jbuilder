# frozen_string_literal: true

json.filters do
  json.name do
    json.type 'text'
    json.label 'Name'
    json.scopes do
      json.name_cont 'contains'
      json.name_not_cont 'does not contain'
      json.name_has_any_term 'is one of'
      json.name_has_every_term 'is all of'
    end
    json.sortable 'name'
  end

  AttributeBuilder.text   json, :names_first_name
  AttributeBuilder.text   json, :names_middle_name
  AttributeBuilder.text   json, :names_last_name

  AttributeBuilder.enumeration json, Person, :sex
  AttributeBuilder.enumeration json, Person, :race, choices: Person.pluck('distinct race').compact.sort

  AttributeBuilder.text json, :pob

  AttributeBuilder.text json, :description

end
