class Industry1930Code < ApplicationRecord
  def self.select_options
    order(:code).map { |item| ["#{item.code} - #{item.name[0..45]}", item.id]}
  end

  def name_with_code
    [code, name].join(' - ')
  end
end
