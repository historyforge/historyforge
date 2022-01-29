# frozen_string_literal: true

class DocumentCategory < ApplicationRecord
  acts_as_list
  has_many :documents, dependent: :nullify
end
