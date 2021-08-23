# frozen_string_literal: true

class CensusRecordDecorator < ApplicationDecorator
  def name
    "#{last_name}, #{first_name} #{middle_name}".strip
  end

  def age
    if object.age_months
      if object.age.blank?
        "#{object.age_months}mo"
      else
        "#{object.age}y #{object.age_months}mo"
      end
    else
      object.age
    end
  end

  def locality
    object.locality&.name
  end

  %w[foreign_born can_read can_write can_speak_english foreign_born unemployed attended_school
     blind deaf_dumb has_radio lives_on_farm can_read_write
     worked_yesterday veteran residence_1935_farm private_work public_work
     seeking_work had_job had_unearned_income veteran_dead soc_sec deductions
     multi_marriage].each do |method|
    define_method method do
      yes_or_blank object.send(method)
    end
  end

  %w[race marital_status sex naturalized_alien employment worker_class
     owned_or_rented mortgage farm_or_house civil_war_vet war_fought].each do |method|
    define_method method do
      census_code object.public_send(method), method
    end
  end

  def census_scope
    str = []
    str << "Ward #{object.ward} " if object.ward.present?
    str << "ED #{object.enum_dist} p. #{object.page_number}#{object.page_side} # #{object.line_number}"
    str.join
  end

  def yes_or_blank(value)
    value && 'Yes' || nil
  end

  def census_code(value, method)
    return '' if value.blank?

    I18n.t("#{method}.#{value.downcase.gsub(/\W/, '')}", scope: 'census_codes', default: value)
  end
end
