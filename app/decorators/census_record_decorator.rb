# frozen_string_literal: true

# All census years share this decorator even though they have different subclasses. The reasoning is simple: the same
# field on each census year should have the same name and output using the same mechanism.
class CensusRecordDecorator < ApplicationDecorator
  def name
    "#{[object.last_name, object.name_suffix].compact.join(' ')}, #{first_name} #{[middle_name, name_prefix].compact.join(', ')}".strip
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

  # Yes/no fields should output Yes if true otherwise nothing.
  %w[foreign_born can_read can_write can_speak_english foreign_born unemployed attended_school
     blind deaf_dumb has_radio lives_on_farm can_read_write
     worked_yesterday veteran residence_1935_farm private_work public_work
     seeking_work had_job had_unearned_income veteran_dead soc_sec deductions
     multi_marriage].each do |method|
    define_method method do
      object.send(method) && 'Yes' || nil
    end
  end

  # Coded answers (enumerations) should output the full text rather than the code.
  %w[race marital_status sex naturalized_alien employment worker_class
     owned_or_rented mortgage farm_or_house civil_war_vet war_fought].each do |method|
    define_method method do
      code = object.public_send(method) rescue NoMethodError
      translate_census_code code, method
    end
  end

  # Outputs a phrase combining ward, enumeration district, sheet, side, and line number so we don't have to occupy
  # multiple columns with this information.
  def census_scope
    str = []
    str << "Ward #{object.ward} " if object.ward.present?
    str << "ED #{object.enum_dist} sh. #{object.page_number}#{object.page_side} # #{object.line_number}"
    str.join
  end

  private

  def translate_census_code(value, method)
    return '' if value.blank?

    I18n.t("#{method}.#{value.downcase.gsub(/\W/, '')}", scope: 'census_codes', default: value)
  end
end
