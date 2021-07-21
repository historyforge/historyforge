json.filters do

  AttributeBuilder.text       json, :street_address
  AttributeBuilder.text       json, :name, label: 'Building Name'

  json.city do
    json.type 'text'
    json.label 'City'
    json.scopes do
      json.city_cont 'contains'
      json.city_not_cont 'does not contain'
      json.city_eq 'equals'
    end
    json.sortable 'city'
  end

  building_types = BuildingType.order(:name).map {|item| [ item.name.capitalize, item.id ]}
  AttributeBuilder.collection json, Building, :building_types_id, building_types

  lining_types = ConstructionMaterial.order(:name).map {|item| [ item.name.capitalize, item.id ]}
  AttributeBuilder.collection json, Building, :lining_type_id, lining_types

  frame_types = ConstructionMaterial.order(:name).map {|item| [ item.name.capitalize, item.id ]}
  AttributeBuilder.collection json, Building, :frame_type_id, frame_types
  AttributeBuilder.text       json, :block_number
  json.as_of_year do
    json.type 'number'
    json.label 'As of Year'
    json.scopes do
      json.as_of_year_eq 'equals'
    end
  end

  AttributeBuilder.time       json, :year_earliest
  AttributeBuilder.time       json, :year_latest
  AttributeBuilder.number     json, :stories
  AttributeBuilder.text       json, :description
  AttributeBuilder.text       json, :annotations

  architects = Architect.order(:name).map {|item| [item.name, item.id] }
  AttributeBuilder.collection json, Architect, :architects_id, architects

end
