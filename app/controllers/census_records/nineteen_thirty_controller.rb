# frozen_string_literal: true

# Controller for 1930 US Census
module CensusRecords
  class NineteenThirtyController < BaseController
    def year
      1930
    end

    private

    def resource_class
      Census1930Record
    end

    def page_title
      '1930 US Census Records'
    end

    def census_record_search_class
      CensusRecord1930Search
    end
  end
end
