# frozen_string_literal: true

module FormErrors
  extend ActiveSupport::Concern

  private

  # Renders a form action with unprocessable entity status for Turbo compatibility
  # Automatically handles validation error rendering without requiring explicit status codes
  #
  # @param action [Symbol] The action to render (:new, :edit, etc.)
  # @param options [Hash] Additional options to pass to render
  # @example
  #   if @record.save
  #     redirect_to @record
  #   else
  #     render_form_with_errors(:new)
  #   end
  def render_form_with_errors(action, **options)
    render({ action: action, status: :unprocessable_entity }.merge(options))
  end
end

