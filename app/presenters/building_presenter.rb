class BuildingPresenter < ApplicationPresenter
  def building_type
    model.building_type_name.andand.capitalize || 'Unknown'
  end

  def street_address
    [model.address_house_number, model.address_street_prefix, model.address_street_name, model.address_street_suffix].join(' ')
  end

  def year_earliest
    return model.year_earliest if model.year_earliest.present?
    model.year_earliest_circa.present? ? "ca. #{model.year_earliest_circa}" : 'Unknown'
  end

  def year_latest
    return model.year_latest if model.year_latest.present?
    model.year_latest_circa.present? ? "ca. #{model.year_latest_circa}" : 'Unknown'
  end

  def name
    model.name || 'Unnamed'
  end

  def architects
    model.architects.andand.map(&:name).andand.join(', ') || 'Unknown'
  end

  def lining_type
    model.lining_type.andand.name.andand.capitalize || 'Unknown'
  end

  def frame_type
    model.frame_type.andand.name.andand.capitalize || 'Unknown'
  end

  def stories
    model.stories.present? ? (model.stories % 1 == 0 ? model.stories.to_i : model.stories) : 'Unknown'
  end

  def field_for(col)
    method = col.clone.to_s
    method << "_name" if method.ends_with?('type')
    field = method.to_sym
    return public_send(field) if respond_to?(field)
    return model.public_send(field) if model.respond_to?(field)
    '?'
  end
end
