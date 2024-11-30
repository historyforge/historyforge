# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include DefineEnumeration
  include AutoStripAttributes
  include AutoUpcaseAttributes
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

  def self.ransackable_attributes(_auth_object = nil)
    columns.map(&:name)
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  def self.decorator_class
    @decorator_class ||= "#{name}Decorator".safe_constantize || "#{superclass&.name}Decorator".constantize
  end

  def decorate(decorator = nil)
    (decorator || self.class.decorator_class).decorate(self)
  end

  def self.human_name
    name
  end
end
