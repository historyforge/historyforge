# frozen_string_literal: true

# Provides scopes and methods related to person names.
module PersonNames
  extend ActiveSupport::Concern

  module NameCleaning
    refine String do
      def clean
        gsub(/\./, ' ').squish
      end
    end
  end
  using NameCleaning

  included do
    before_validation :clean_name
    before_save :set_searchable_name

    scope :by_name, -> { order(:last_name, :first_name, :middle_name) }
    scope :fuzzy_name_search, lambda { |names|
      Array.wrap(names).map { |name| where('searchable_name % ?', name) }.reduce(:or)
    }

    ransacker :name, formatter: proc { |v| v.mb_chars.downcase.to_s } do |parent|
      Arel::Nodes::NamedFunction.new('LOWER',
                                     [Arel::Nodes::NamedFunction.new('concat_ws',
                                                                     [Arel::Nodes::Quoted.new(' '),
                                                                      parent.table[:name_prefix],
                                                                      parent.table[:first_name],
                                                                      parent.table[:middle_name],
                                                                      parent.table[:last_name],
                                                                      parent.table[:name_suffix]])])
    end

    def name
      [name_prefix, first_name, middle_name, last_name, name_suffix].select(&:present?).join(' ')
    end

    private

    def set_searchable_name
      self.searchable_name = name
      self.sortable_name = [last_name, first_name, middle_name].join(' ')
    end

    def clean_name
      %i[name_prefix first_name middle_name last_name name_suffix].each do |attribute|
        self[attribute] = self[attribute].clean if self[attribute]
      end
    end
  end
end
