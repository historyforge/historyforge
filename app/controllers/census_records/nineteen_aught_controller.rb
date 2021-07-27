# frozen_string_literal: true

# Controller for 1900 US Census
module CensusRecords
  class NineteenAughtController < BaseController
    def year
      1900
    end

    private

    def resource_class
      Census1900Record
    end

    def page_title
      '1900 US Census Records'
    end

    def census_record_search_class
      CensusRecord1900Search
    end
  end
end
