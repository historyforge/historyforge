class CensusRecordPresenter < ApplicationPresenter
  def name
    "#{last_name}, #{first_name} #{middle_name}".strip
  end

  def age
    if model.age_months
      if model.age.blank?
        "#{model.age_months}mo"
      else
        "#{model.age}y #{model.age_months}mo"
      end
    else
      model.age
    end
  end

  def locality
    model.locality.name
  end

  %w{foreign_born can_read can_write can_speak_english foreign_born unemployed attended_school
     blind deaf_dumb has_radio lives_on_farm can_read_write
     worked_yesterday veteran residence_1935_farm private_work public_work
     seeking_work had_job had_unearned_income veteran_dead soc_sec deductions multi_marriage
  }.each do |method|
    define_method method do
      yes_or_blank model.send(method)
    end
  end

  def census_scope
    str = ''
    str << "Ward #{model.ward} " if model.ward.present?
    str << "ED #{model.enum_dist} p. #{model.page_number}#{model.page_side} # #{model.line_number}"
    str
  end

  def field_for(field)
    return public_send(field) if respond_to?(field)
    return census_code(model.public_send(field), field) if model.class.enumerations.include?(field.intern)
    return model.public_send(field) if model.respond_to?(field)
    '?'
  end

  def yes_or_blank(value)
    value && 'Yes' || nil
  end

  def census_code(value, method)
    return '' if value.blank?

    I18n.t("#{method}.#{value.downcase.gsub(/\W/, '')}", scope: 'census_codes', default: value)
  end
end
