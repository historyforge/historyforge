module Flaggable
  extend ActiveSupport::Concern
  included do
    has_many :flags, as: :flaggable, dependent: :destroy
  end
end