# frozen_string_literal: true

# Controller for 1910 US Census
module CensusRecords
  class NineteenTenController < BaseController
    def year
      1910
    end

    private

    def resource_class
      Census1910Record
    end

    def page_title
      '1910 US Census Records'
    end

    def census_record_search_class
      CensusRecord1910Search
    end
  end
end
