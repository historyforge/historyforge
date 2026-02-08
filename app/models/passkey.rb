# frozen_string_literal: true

class Passkey < ApplicationRecord
  belongs_to :user

  validates :label, presence: true
  validates :external_id, presence: true, uniqueness: true
  validates :public_key, presence: true, uniqueness: true
  validates :sign_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :active, -> { where.not(public_key: nil) }
end
