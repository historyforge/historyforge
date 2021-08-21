# frozen_string_literal: true

class CensusRecord1910Search < CensusRecordSearch
  def form_fields_config
    Census1910FormFields
  end

  def entity_class
    Census1910Record
  end
end
