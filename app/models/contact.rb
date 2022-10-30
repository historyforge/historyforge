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

  json_attribute :subject
  json_attribute :message
  json_attribute :name
  json_attribute :email
  json_attribute :phone
  json_attribute :organization
  json_attribute :how_heard

  validates :subject, :message, :name, :email, presence: true
end
