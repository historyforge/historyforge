# frozen_string_literal: true

# Controller for 1920 US Census
module CensusRecords
  class NineteenTwentyController < BaseController
    def year
      1920
    end

    private

    def resource_class
      Census1920Record
    end

    def page_title
      '1920 US Census Records'
    end

    def census_record_search_class
      CensusRecord1920Search
    end
  end
end
