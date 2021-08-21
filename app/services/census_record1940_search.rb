# frozen_string_literal: true

class CensusRecord1940Search < CensusRecordSearch
  def form_fields_config
    Census1940FormFields
  end

  def entity_class
    Census1940Record
  end
end
