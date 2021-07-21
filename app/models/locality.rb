class Locality < ApplicationRecord
  has_many :census1900_records, inverse_of: :locality
  has_many :census1910_records, inverse_of: :locality
  has_many :census1920_records, inverse_of: :locality
  has_many :census1930_records, inverse_of: :locality
  has_many :census1940_records, inverse_of: :locality

  def self.select_options
    order(:position).map { |item| [item.name, item.id] }
  end
end
