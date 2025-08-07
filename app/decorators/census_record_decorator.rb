# frozen_string_literal: true

# All census years share this decorator even though they have different subclasses. The reasoning is simple: the same
# field on each census year should have the same name and output using the same mechanism.
class CensusRecordDecorator < ApplicationDecorator
  include DecoratorFormatting

  def age
    return 'Un.' if object&.age == 999

    if object.year == 1950
      object.age&.positive? ? object.age : '<1'
    elsif object.age_months
      object.age.blank? ? "#{object.age_months}mo" : "#{object.age}y #{object.age_months}mo"
    else
      object.age
    end
  end

  def birth_month
    return if object.birth_month.nil?

    object.year == 1950 ? object.birth_month : Date::MONTHNAMES[object.birth_month.to_i]
  end

  def locality
    object.locality&.short_name
  end

  def locality_id
    object.locality&.short_name
  end

  # Yes/no fields should output Yes if true otherwise nothing.
  %w[foreign_born father_foreign_born mother_foreign_born can_read can_write can_speak_english unemployed
     attended_school blind deaf_dumb has_radio lives_on_farm lives_on_3_acres can_read_write idiotic insane maimed
     cannot_read cannot_write just_married homemaker income_plus pauper convict cannot_read_write
     worked_yesterday veteran residence_1935_farm private_work public_work
     seeking_work had_job had_unearned_income veteran_dead soc_sec deductions
     newlyweds item_20_entries veteran_other veteran_ww1 veteran_ww2 finished_grade
     same_house_1949 on_farm_1949 same_county_1949 employed_absent worked_last_week
     multi_marriage full_citizen denied_citizen].each do |method|
    define_method method do
      object.send(method) && 'Yes' || nil
    end
  end

  def attended_school
    return unless object.attended_school?

    if object.year == 1900
      object.attended_school == 1 ? '1 month' : "#{object.attended_school} months"
    else
      object.attended_school? ? 'Yes' : nil
    end
  end

  # Coded answers (enumerations) should output the full text rather than the code.
  %w[race marital_status sex naturalized_alien employment worker_class
     owned_or_rented mortgage farm_or_house civil_war_vet war_fought].each do |method|
    define_method method do
      code = object.public_send(method)
      translate_census_code code, method
    rescue NoMethodError
      nil
    end
  end

  # Outputs a phrase combining ward, enumeration district, sheet, side, and line number so we don't have to occupy
  # multiple columns with this information.
  def census_scope
    str = []
    str << "Ward #{object.ward} " if object.ward.present?
    str << "ED #{object.enum_dist} " if object.respond_to?(:enum_dist)
    str << "Sheet #{object.page_number}#{object.page_side} ##{object.line_number}"
    str.join
  end

  def census_person_id
    # Try the direct attribute first
    return object.census_person_id if object.respond_to?(:census_person_id) && object.census_person_id.present?

    # Fall back to extracting from notes
    extracted_id = object&.notes&.match(/(?:ID: )(P-\d+)/)&.[](1)
    return extracted_id if extracted_id.present?

    # Return nil if neither method works
    nil
  end

  private

  def translate_census_code(value, method)
    return '' if value.blank?

    I18n.t("#{method}.#{value.downcase.gsub(/\W/, '')}", scope: 'census_codes', default: value)
  end
end
