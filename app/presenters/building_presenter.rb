class BuildingPresenter < ApplicationPresenter
  def building_type_name
    model.building_type_name&.capitalize || 'Unknown'
  end

  def locality
    model.locality&.name || 'None'
  end

  def street_address
    model.primary_street_address
    # [model.address_house_number, model.address_street_prefix, model.address_street_name, model.address_street_suffix].join(' ')
  end

  def year_earliest
    return model.year_earliest if model.year_earliest.present?

    model.year_earliest_circa.present? ? "ca. #{model.year_earliest_circa}" : ''
  end

  def year_latest
    return model.year_latest if model.year_latest.present?

    model.year_latest_circa.present? ? "ca. #{model.year_latest_circa}" : ''
  end

  def name
    model.name || 'Unnamed'
  end

  def architects
    model.architects&.map(&:name)&.join(', ') || ''
  end

  def lining_type_name
    model.lining_type&.name&.capitalize || ''
  end

  def frame_type_name
    model.frame_type&.name&.capitalize || ''
  end

  def stories
    model.stories.present? ? (model.stories % 1 == 0 ? model.stories.to_i : model.stories) : ''
  end

  def field_for(col)
    method = col.clone.to_s
    method << '_name' if method.ends_with?('type')
    field = method.to_sym
    return public_send(field) if respond_to?(field)
    return model.public_send(field) if model.respond_to?(field)

    '?'
  end
end
