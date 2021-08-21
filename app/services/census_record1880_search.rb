# frozen_string_literal: true

class CensusRecord1880Search < CensusRecordSearch
  def form_fields_config
    Census1880FormFields
  end

  def entity_class
    Census1880Record
  end
end
