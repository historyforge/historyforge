# frozen_string_literal: true

# Provides paper trail behavior to models along with a method that plays well wtih shared/_change_history.html.slim.
module Versioning
  extend ActiveSupport::Concern

  included do
    attr_accessor :comment

    has_paper_trail meta: { comment: :comment }, skip: %i[created_at updated_at]

    def change_history
      return @change_history if defined?(@change_history)

      @change_history = versions.includes(:item).reverse
    end
  end
end
