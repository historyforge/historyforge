# frozen_string_literal: true

class CensusRecord1920Search < CensusRecordSearch
  def form_fields_config
    Census1920FormFields
  end

  def entity_class
    Census1920Record
  end
end
