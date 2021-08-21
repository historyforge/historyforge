# frozen_string_literal: true

class CensusRecord1900Search < CensusRecordSearch
  def form_fields_config
    Census1900FormFields
  end

  def entity_class
    Census1900Record
  end
end
