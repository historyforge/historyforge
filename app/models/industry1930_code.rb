# == Schema Information
#
# Table name: industry1930_codes
#
#  id         :integer          not null, primary key
#  code       :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# frozen_string_literal: true

class Industry1930Code < ApplicationRecord
  def self.select_options
    order(:code).map { |item| ["#{item.code} - #{item.name[0..45]}", item.id]}
  end

  def name_with_code
    [code, name].join(' - ')
  end
end
