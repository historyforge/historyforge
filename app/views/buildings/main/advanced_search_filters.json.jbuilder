json.filters do

  localities = Locality.order(:name).map { |item| [item.name, item.id] }
  AttributeBuilder.collection json, :locality_id, klass: Building, collection: localities
  AttributeBuilder.text       json, :street_address, label: 'Street Address'
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

  building_types = BuildingType.order(:name).map { |item| [item.name.capitalize, item.id] }
  AttributeBuilder.collection json, :building_types_id, klass: Building, collection: building_types

  lining_types = ConstructionMaterial.order(:name).map { |item| [item.name.capitalize, item.id] }
  AttributeBuilder.collection json, :lining_type_id, klass: Building, collection: lining_types

  frame_types = ConstructionMaterial.order(:name).map { |item| [item.name.capitalize, item.id] }
  AttributeBuilder.collection json, :frame_type_id, klass: Building, collection: frame_types
  AttributeBuilder.text       json, :block_number
  json.as_of_year do
    json.type 'number'
    json.label 'As of Year'
    json.scopes do
      json.as_of_year_eq 'equals'
    end
  end

  AttributeBuilder.time       json, :year_earliest, label: 'Year Built'
  AttributeBuilder.time       json, :year_latest, label: 'Year Demolished'
  AttributeBuilder.number     json, :stories
  AttributeBuilder.text       json, :description
  AttributeBuilder.text       json, :annotations

  architects = Architect.order(:name).map {|item| [item.name, item.id] }
  AttributeBuilder.collection json, :architects_id, klass: Architect, collection: architects

end
