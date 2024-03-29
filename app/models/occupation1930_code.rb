# == Schema Information
#
# Table name: occupation1930_codes
#
#  id         :bigint           not null, primary key
#  code       :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# frozen_string_literal: true

class Occupation1930Code < ApplicationRecord
  def self.select_options
    order(:code).map { |item| ["#{item.code} - #{item.name[0..45]}", item.id]}
  end

  def name_with_code
    [code, name].join(' - ')
  end
end
