# frozen_string_literal: true

module CensusRecords
  # Creates audit logs and updates estimated age and birthplace for person records.
  class AuditPersonConnection
    def self.call(person_from: nil, person_to: nil, year:, name:)
      new(person_from:, person_to:, year:, name:).call
    end

    def initialize(person_from: nil, person_to: nil, year:, name:)
      @person_from = person_from
      @person_to = person_to
      @year = year
      @name = name
    end

    def call
      handle_connected_person if person_to.present?
      handle_disconnected_person if person_from.present?
    end

    private

    attr_reader :person_from, :person_to, :year, :name

    def handle_connected_person
      person_to.save_with_estimates
      person_to.audit_logs.create message: "Connected to #{year} Census Record for #{name}"
    end

    def handle_disconnected_person
      person_from.audit_logs.create message: "Disconnected from #{year} Census Record for #{name}"
      person_from.save_with_estimates
      person_from.save
    end
  end
end
