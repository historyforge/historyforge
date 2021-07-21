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

  # json.pob do
  #   json.type 'text'
  #   json.label 'POB'
  #   json.scopes do
  #     json.pob_cont 'contains'
  #     json.pob_not_cont 'does not contain'
  #     json.pob_eq 'equals'
  #     json.pob_has_any_term 'is one of'
  #     json.pob_has_every_term 'is all of'
  #   end
  #   json.sortable 'pob'
  # end
  #
  # json.profession do
  #   json.type 'text'
  #   json.label 'Profession'
  #   json.scopes do
  #     json.profession_cont 'contains'
  #     json.profession_not_cont 'does not contain'
  #     json.profession_eq 'equals'
  #     json.profession_has_any_term 'is one of'
  #     json.profession_has_every_term 'is all of'
  #   end
  #   json.sortable 'profession'
  # end

  AttributeBuilder.text   json, :first_name
  AttributeBuilder.text   json, :middle_name
  AttributeBuilder.text   json, :last_name

  AttributeBuilder.enumeration json, Person, :sex


end
