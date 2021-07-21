# == Schema Information
#
# Table name: documents
#
#  id          :integer          not null, primary key
#  file        :string
#  name        :string
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Document < ApplicationRecord

  belongs_to :document_category
  acts_as_list scope: :document_category_id
  has_one_attached :file
  before_save :assign_name_from_file

  private

  def assign_name_from_file
    self.name = file.filename if name.blank? && file.attached?
  end

end
