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

  has_and_belongs_to_many :localities
  belongs_to :document_category
  has_and_belongs_to_many :buildings
  has_and_belongs_to_many :people
  acts_as_list scope: :document_category_id
  has_one_attached :file
  before_save :assign_name_from_file
  scope :available_to_public, -> { where(available_to_public: true) }
  scope :authorized_for, ->(user) { user.blank? ? available_to_public : self }

  # @param locality_id [Integer, nil]
  # @return [ActiveRecord::Relation]
  def self.for_locality_id(locality_id)
    if locality_id
      joins('LEFT JOIN documents_localities ON documents_localities.document_id=documents.id')
        .where('locality_id IS NULL OR locality_id=?', locality_id)
    else
      all
    end
  end

  private

  def assign_name_from_file
    self.name = file.filename if name.blank? && file.attached?
  end

end
