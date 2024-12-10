# frozen_string_literal: true

# Provides paper trail behavior to models along with a method that plays well wtih shared/_change_history.html.slim.
module Versioning
  extend ActiveSupport::Concern

  included do
    attr_accessor :comment

    has_many :audit_logs, as: :loggable

    has_paper_trail meta: { comment: :comment },
                    skip: %i[created_at reviewed_at updated_at created_by_id reviewed_by_id updated_by_id searchable_text]

    def change_history
      return @change_history if defined?(@change_history)

      version_history = versions.includes(:item).select { |v| v.changeset.present? }
      version_history += audit_logs
      if respond_to?(:reviewed_at) && reviewed_at.present?
        version_history << AuditLog.new(message: "Reviewed", logged_at: reviewed_at, user_id: reviewed_by_id)
      end
      @change_history = version_history.sort_by(&:created_at).reverse
    end
  end
end
