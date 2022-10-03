# frozen_string_literal: true

# Provides paper trail behavior to models along with a method that plays well wtih shared/_change_history.html.slim.
module Versioning
  extend ActiveSupport::Concern

  included do
    attr_accessor :comment

    has_paper_trail meta: { comment: :comment },
                    skip: %i[created_at reviewed_at updated_at created_by_id reviewed_by_id updated_by_id]

    def change_history
      return @change_history if defined?(@change_history)

      @change_history = versions.includes(:item).select { |v| v.changeset.present? }.reverse
    end
  end
end
