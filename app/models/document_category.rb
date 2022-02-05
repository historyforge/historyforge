# == Schema Information
#
# Table name: document_categories
#
#  id          :integer          not null, primary key
#  name        :string
#  description :text
#  position    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

# frozen_string_literal: true

class DocumentCategory < ApplicationRecord
  acts_as_list
  has_many :documents, dependent: :nullify
end
