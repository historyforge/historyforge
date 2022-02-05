# == Schema Information
#
# Table name: addresses
#
#  id           :integer          not null, primary key
#  building_id  :integer          not null
#  is_primary   :boolean          default("false")
#  house_number :string
#  prefix       :string
#  name         :string
#  suffix       :string
#  city         :string
#  postal_code  :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  year         :integer
#
# Indexes
#
#  index_addresses_on_building_id  (building_id)
#

# frozen_string_literal: true

class Address < ApplicationRecord
  include AutoStripAttributes

  belongs_to :building

  alias_attribute :street_name, :name
  alias_attribute :street_prefix, :prefix
  alias_attribute :street_suffix, :suffix

  auto_strip_attributes :city, :house_number, :name, :prefix, :suffix
  validates :year, numericality: { minimum: 1500, maximum: 2100, allow_nil: true }

  ransacker :street_address, formatter: proc { |v| v.mb_chars.downcase.to_s } do |parent|
    Arel::Nodes::NamedFunction.new('LOWER',
                                   [Arel::Nodes::NamedFunction.new('concat_ws',
                                                                   [Arel::Nodes::Quoted.new(' '),
                                                                    parent.table[:house_number],
                                                                    parent.table[:prefix],
                                                                    parent.table[:name],
                                                                    parent.table[:suffix]
                                                                   ])])
  end

  def <=>(other)
    (other.year || 0) <=> (year || 0)
  end

  def address
    [house_number, prefix, name, suffix].join(' ')
  end

  def equals?(address)
    house_number == address.house_number && prefix == address.prefix && name == address.name && suffix == address.suffix
  end

  def self.from(item)
    if item.kind_of?(Building)
      item.addresses.find_or_create_by(
        house_number: item.read_attribute(:address_house_number),
        prefix: item.read_attribute(:address_street_prefix),
        name: item.read_attribute(:address_street_name),
        suffix: item.read_attribute(:address_street_suffix),
        city: item.read_attribute(:city),
        year: item.read_attribute(:address_year_earliest),
        is_primary: true
      )
    elsif item.kind_of?(CensusRecord)
      return if item.building_id.blank?

      item.building.addresses.find_or_create_by(
        house_number: item.read_attribute(:street_house_number),
        prefix: item.read_attribute(:street_prefix),
        name: item.read_attribute(:street_name),
        suffix: item.read_attribute(:street_suffix),
        city: item.read_attribute(:city),
        year: item.read_attribute(:year_earliest),
      )
    end
  end
end
