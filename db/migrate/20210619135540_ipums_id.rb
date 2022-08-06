# frozen_string_literal: true

class IpumsId < ActiveRecord::Migration[6.0]
  def change
    add_column :terms, :ipums, :integer
  end
end
