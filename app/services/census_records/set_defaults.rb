# frozen_string_literal: true

module CensusRecords
  # Sets default attributes on a new census record object.
  class SetDefaults < ApplicationInteraction
    object :record, class: 'CensusRecord'

    def execute
      set_defaults unless record.persisted?
    end

    def set_defaults
      set_base_defaults
      set_pre_1940_defaults if record.year <= 1940
    end

    def set_base_defaults
      record.city   ||= AppConfig[:city]
      record.county ||= AppConfig[:county]
      record.state  ||= AppConfig[:state]
      record.pob    ||= AppConfig[:pob]
    end

    def set_pre_1940_defaults
      record.pob_mother ||= AppConfig[:pob]
      record.pob_father ||= AppConfig[:pob]
    end
  end
end
