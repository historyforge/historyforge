# frozen_string_literal: true
# == Schema Information
#
# Table name: documents
#
#  id                   :bigint           not null, primary key
#  document_category_id :bigint
#  file                 :string
#  name                 :string
#  description          :text
#  position             :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  url                  :string
#  available_to_public  :boolean          default(FALSE)
#
# Indexes
#
#  index_documents_on_document_category_id  (document_category_id)
#

class Document < ApplicationRecord

  belongs_to :document_category
  acts_as_list scope: :document_category_id
  has_one_attached :file
  before_save :assign_name_from_file
  scope :available_to_public, -> { where(available_to_public: true) }
  scope :authorized_for, ->(user){ user.blank? ? available_to_public : self }
  private

  def assign_name_from_file
    self.name = file.filename if name.blank? && file.attached?
  end

end
