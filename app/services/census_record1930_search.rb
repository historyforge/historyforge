# frozen_string_literal: true

class CensusRecord1930Search < CensusRecordSearch
  def form_fields_config
    Census1930FormFields
  end

  def entity_class
    Census1930Record
  end
end
