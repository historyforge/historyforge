# frozen_string_literal: true

module CensusRecords
  # Provides support for address formatting and searching.
  module Addressable
    extend ActiveSupport::Concern

    included do
      attr_accessor :ensure_building

      ransacker :street_address, formatter: proc { |v|
        ReverseStreetConversion.convert(v).to_s.mb_chars.downcase.to_s
      } do |parent|
        Arel::Nodes::NamedFunction.new('LOWER',
                                       [Arel::Nodes::NamedFunction.new('concat_ws',
                                                                       [Arel::Nodes::Quoted.new(' '),
                                                                        parent.table[:street_house_number],
                                                                        parent.table[:street_prefix],
                                                                        parent.table[:street_name],
                                                                        parent.table[:street_suffix]])])
      end
    end

    def street_address
      [street_house_number, street_prefix, street_name, street_suffix,
       apartment_number ? "Apt. #{apartment_number}" : nil].compact.join(' ')
    end

    delegate :latitude, :longitude, to: :building, allow_nil: true
  end
end
