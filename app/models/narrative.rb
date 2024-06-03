class Narrative < ApplicationRecord
  include Flaggable
  include Moderation
  include MediaDateBehavior

  has_and_belongs_to_many :buildings
  has_and_belongs_to_many :people

  has_rich_text :story
  validates :story, presence: true

  default_scope -> { order(:weight) }
  scope :with_attached_file, -> { with_all_rich_text }
  scope :unreviewed_only, ->(val) { val == '1' ? unreviewed : self }

  def self.ransackable_scopes(_auth_object=nil)
    %i[unreviewed_only]
  end

  def process = nil
end
