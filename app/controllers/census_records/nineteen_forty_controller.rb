# frozen_string_literal: true

# Controller for 1940 US Census
module CensusRecords
  class NineteenFortyController < BaseController
    def year
      1940
    end

    private

    def resource_class
      Census1940Record
    end

    def page_title
      '1940 US Census Records'
    end

    def census_record_search_class
      CensusRecord1940Search
    end
  end
end
