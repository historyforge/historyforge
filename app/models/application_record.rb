# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include FastMemoize

  self.abstract_class = true

  def self.current_table_name
    current_table = current_scope.arel.source.left

    case current_table
    when Arel::Table
      current_table.name
    when Arel::Nodes::TableAlias
      current_table.right
    else
      raise
    end
  end
end
