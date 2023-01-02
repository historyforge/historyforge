# frozen_string_literal: true

class CreateSettings < ActiveRecord::Migration[6.0]
  def up
    return if table_exists?(:settings)

    sql = File.open(Rails.root.join('db', 'structure.sql')).read
    execute sql
  end

  def down
  end
end
