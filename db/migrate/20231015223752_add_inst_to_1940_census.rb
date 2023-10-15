# frozen_string_literal: true

class AddInstTo1940Census < ActiveRecord::Migration[7.0]
  def change
    add_column :census_1940_records, :institutional_work, :boolean, after: :private_work
  end
end
