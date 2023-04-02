# frozen_string_literal: true

# When adding a new record, users can choose to "save and add a new record in the same...". This service
# fills in the attributes for the next record. If you're at the end of the sheet or side, it will start the
# next one.
class NextCensusRecordAttributes
  ALWAYS_FIELDS = %i[county city ward enum_dist locality_id].freeze

  AFTER_SAVED_FIELDS = {
    'page' => [],
    'enumeration' => [],
    'street' => %i[street_prefix street_suffix street_name],
    'dwelling' => %i[dwelling_number street_house_number
                     street_prefix street_suffix street_name apartment_number building_id],
    'family' => %i[dwelling_number street_house_number street_prefix street_suffix street_name apartment_number
                   family_id building_id last_name institution_type institution_name]
  }.freeze

  def initialize(record, action)
    @record = record
    @action = action
    prefill_attributes
    prefill_sheet_side_line
  end

  attr_reader :record, :action, :attributes

  private

  def prefill_attributes
    @attributes = fields.each_with_object({}) { |item, hash|
      hash[item] = record.public_send(item) if record.respond_to?(item)
    }
  end

  def prefill_sheet_side_line
    at_end_of_page? ? start_new_side : start_new_line
  end

  def at_end_of_page?
    record.line_number == record.per_page
  end

  def start_new_side
    attributes[:line_number] = 1
    attributes[:page_side] = record.page_side == 'A' ? 'B' : 'A'
    attributes[:page_number] = record.page_side == 'A' ? record.page_number : record.page_number + 1
  end

  def start_new_line
    attributes[:line_number] = (record.line_number || 0) + 1
    attributes[:page_side] = record.page_side
    attributes[:page_number] = record.page_number
  end

  def fields
    ALWAYS_FIELDS + AFTER_SAVED_FIELDS[action]
  end
end
