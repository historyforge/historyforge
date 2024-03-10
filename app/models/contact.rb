# == Schema Information
#
# Table name: contacts
#
#  id         :bigint           not null, primary key
#  data       :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# frozen_string_literal: true

class Contact < ApplicationRecord
  include ArDocStore::Model

  SPAM_REGEX = /mailto|href|WCRTEST|http/
  URI_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i.freeze

  json_attribute :subject
  json_attribute :message
  json_attribute :name
  json_attribute :email
  json_attribute :phone
  json_attribute :organization
  json_attribute :how_heard

  validates :subject, :message, :name, :email, presence: true
  validate :validate_spam

  def validate_spam
    errors.add(:message, 'Mmmm delicious.') if smells_spammy?
  end

  def smells_spammy?
    message =~ SPAM_REGEX || message =~ URI_REGEX
  end

end
