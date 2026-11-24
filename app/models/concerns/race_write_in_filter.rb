# frozen_string_literal: true

module RaceWriteInFilter
  extend ActiveSupport::Concern

  RACE_WRITE_IN_FILTER = '__race_write_in__'

  NON_WRITE_IN_RACE_VALUES = ['', 'unknown', 'un'].freeze

  included do
    class_attribute :race_write_in_filter, default: false
  end

  class_methods do
    def enable_race_write_in_filter
      self.race_write_in_filter = true
      standard_codes = race_choices.map(&:downcase) + NON_WRITE_IN_RACE_VALUES

      ransacker :race_with_write_ins, type: :string do |parent|
        race = parent.table[:race]
        trimmed = Arel::Nodes::NamedFunction.new('BTRIM', [race])
        normalized = Arel::Nodes::NamedFunction.new('LOWER', [trimmed])
        Arel::Nodes::Case.new.when(normalized.not_in(standard_codes)).then(RACE_WRITE_IN_FILTER).else(race)
      end
    end

    def race_filter_params(params)
      return params unless race_write_in_filter

      params.transform_keys do |key|
        if %w[race_in race_not_in].include?(key.to_s) && Array(params[key]).include?(RACE_WRITE_IN_FILTER)
          key.to_s.sub('race_', 'race_with_write_ins_')
        else
          key
        end
      end
    end
  end
end
