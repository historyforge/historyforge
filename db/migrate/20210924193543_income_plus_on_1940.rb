# frozen_string_literal: true

class IncomePlusOn1940 < ActiveRecord::Migration[6.0]
  def change
    add_column :census_1940_records, :income_plus, :boolean, after: :income
  end
end
