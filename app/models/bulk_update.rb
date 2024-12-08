# == Schema Information
#
# Table name: bulk_updates
#
#  id         :bigint           not null, primary key
#  year       :integer
#  field      :string
#  value_from :string
#  value_to   :string
#  user_id    :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_bulk_updates_on_user_id  (user_id)
#

# frozen_string_literal: true

class BulkUpdate < ApplicationRecord
  # @!attribute confirm
  #   @return [Boolean]
  attr_accessor :confirm

  belongs_to :user
  has_many :records, class_name: 'BulkUpdatedRecord', dependent: :destroy, inverse_of: :bulk_update
  has_many :census_records, through: :records, source: :record, inverse_of: :bulk_updates

  validates :field, presence: true

  def perform
    targets.each do |record|
      record[field] = value_to
      record.comment = comment
      if record.save!
        records.create! record: record
      end
    end
  end

  def targets
    value_from.present? && resource_class.where(field => value_from) || []
  end

  def comment
    @comment ||= "Bulk Update of #{field} from \"#{value_from}\" to \"#{value_to}\"."
  end

  def resource_class
    "Census#{year}Record".safe_constantize
  end

  def confirmed?
    confirm && confirm == '1'
  end
end
