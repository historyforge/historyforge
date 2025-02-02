# == Schema Information
#
# Table name: narratives
#
#  id             :bigint           not null, primary key
#  created_by_id  :bigint           not null
#  reviewed_by_id :bigint
#  reviewed_at    :datetime
#  weight         :integer          default(0)
#  source         :string
#  notes          :text
#  date_type      :integer
#  date_text      :string
#  date_start     :date
#  date_end       :date
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_narratives_on_created_by_id   (created_by_id)
#  index_narratives_on_reviewed_by_id  (reviewed_by_id)
#
class Narrative < ApplicationRecord
  include Flaggable
  include Moderation
  include Versioning
  include MediaDateBehavior

  has_and_belongs_to_many :buildings
  has_and_belongs_to_many :people

  has_rich_text :story
  has_rich_text :sources
  validates :story, :sources, presence: true

  default_scope -> { order(:weight) }
  scope :with_attached_file, -> { with_all_rich_text }
  scope :unreviewed_only, ->(val) { val == '1' ? unreviewed : self }

  def self.ransackable_scopes(_auth_object=nil)
    %i[unreviewed_only full_text_search]
  end

  def process = nil
end
