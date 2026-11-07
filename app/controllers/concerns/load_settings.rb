# frozen_string_literal: true

module LoadSettings
  extend ActiveSupport::Concern

  included do
    around_action :load_settings
  end

  private

  def load_settings
    Setting.load
    yield
  ensure
    Setting.unload
  end
end
