# frozen_string_literal: true

module CensusRecords
  # Sets default attributes on a new census record object.
  class SetDefaults
    def self.call(record:)
      new(record:).call
    end

    def initialize(record:)
      @record = record
    end

    def call
      set_defaults unless record.persisted?
    end

    private

    attr_reader :record

    def set_defaults
      set_base_defaults
      set_pre_1940_defaults if record.year < 1940 && record.year > 1870
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
