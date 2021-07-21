class BulkUpdate < ApplicationRecord
  attr_accessor :confirm
  belongs_to :user
  has_many :records, class_name: 'BulkUpdatedRecord', dependent: :destroy
  has_many :census_records, through: :records, source: :record

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