class Locality < ApplicationRecord
  CensusYears.each do |year|
    has_many :"census#{year}_records", inverse_of: :locality
  end

  def self.select_options
    order(:position).map { |item| [item.name, item.id] }
  end
end
