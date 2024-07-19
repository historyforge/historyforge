# frozen_string_literal: true

module CensusRecords
  # Creates audit logs and updates estimated age and birthplace for person records.
  class AuditPersonConnection < ApplicationInteraction
    record :person_from, class: Person, default: nil
    record :person_to, class: Person, default: nil
    integer :year
    string :name

    def execute
      handle_connected_person if person_to.present?
      handle_disconnected_person if person_from.present?
    end

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
