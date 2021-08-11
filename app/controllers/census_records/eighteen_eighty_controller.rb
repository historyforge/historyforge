# frozen_string_literal: true

# Controller for 1880 US Census
module CensusRecords
  class EighteenEightyController < BaseController
    def year
      1880
    end

    private

    def resource_class
      Census1880Record
    end

    def page_title
      '1880 US Census Records'
    end

    def census_record_search_class
      CensusRecord1880Search
    end
  end
end
