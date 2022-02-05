# == Schema Information
#
# Table name: street_conversions
#
#  id                :integer          not null, primary key
#  from_prefix       :string
#  to_prefix         :string
#  from_name         :string
#  to_name           :string
#  from_suffix       :string
#  to_suffix         :string
#  from_city         :string
#  to_city           :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  from_house_number :string
#  to_house_number   :string
#  year              :integer
#

# frozen_string_literal: true

class StreetConversion < ApplicationRecord
  after_commit :update_address_history

  def description
    from = [from_house_number, from_prefix, from_name, from_suffix, from_city].select(&:present?).join(' ')
    to   = [to_house_number, to_prefix,   to_name,   to_suffix,   to_city].select(&:present?).join(' ')
    "#{from} => #{to}"
  end

  def matches?(address)
    needed_matches = [from_house_number, from_prefix, from_name, from_suffix, from_city].select(&:present?).size
    matches = 0
    matches += 1 if from_house_number.present? && address.house_number == from_house_number
    matches += 1 if from_prefix.present? && address.street_prefix == from_prefix
    matches += 1 if from_name.present? && address.street_name == from_name
    matches += 1 if from_suffix.present? && address.street_suffix == from_suffix
    matches += 1 if from_city.present? && address.city == from_city
    matches == needed_matches
  end

  def convert(address)
    address.house_number  = convert_attribute 'house_number'
    address.street_prefix = convert_attribute 'prefix'
    address.street_name   = convert_attribute 'name'
    address.street_suffix = convert_attribute 'suffix'
    address.city          = convert_attribute 'city'
    address.year          = year
    address
  end

  def convert_attribute(attr)
    from = public_send("from_#{attr}")
    to   = public_send("to_#{attr}")
    if to.present?
      to == 'null' ? nil : to
    else
      from
    end
  end

  def self.convert(address)
    converter = all.detect { |record| record.matches?(address) }
    converter ? converter.convert(address) : address
  end

  def update_address_history
    AddressHistoryFromStreetConversion.new(self).perform
  end
end
