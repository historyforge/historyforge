# frozen_string_literal: true

class GenerateAuditLogsJob < ApplicationJob
  def perform
    PaperTrail::Version.find_each do |version|
      person_change = version.changeset[:person_id]
      if person_change
        from_person_id, to_person_id = person_change
        next unless version.item.present?

        user = User.find_by id: version.whodunnit
        next if user.blank?

        if to_person_id.present?
          Person.find_by(id: to_person_id)&.audit_logs&.create message: "Connected to #{version.item.year} Census Record for #{version.item.name}",
                                                               logged_at: version.created_at,
                                                               user_id: version.whodunnit
        end
        if from_person_id.present?
          Person.find_by(id: from_person_id)&.audit_logs&.create message: "Disconnected from #{version.item.year} Census Record for #{version.item.name}",
                                                                 logged_at: version.created_at,
                                                                 user_id: version.whodunnit
        end

      end
    end
  end
end
