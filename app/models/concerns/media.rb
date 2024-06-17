# frozen_string_literal: true

module Media
  extend ActiveSupport::Concern
  included do
    include PgSearch::Model
    include Flaggable
    include Moderation
    include Versioning

    has_and_belongs_to_many :buildings
    has_and_belongs_to_many :people
    has_one_attached :file

    alias_attribute :title, :caption
    alias_attribute :name, :caption

    pg_search_scope :full_text_search,
                    against: %i[caption location notes],
                    using: {
                      tsearch: { prefix: true, any_word: true }
                    }

    scope :unreviewed_only, ->(val) { val == '1' ? unreviewed : self }

    def self.ransackable_scopes(_auth_object=nil)
      %i[full_text_search unreviewed_only]
    end
  end

  def full_caption
    items = [caption]
    items << date_text if date_text?
    items.compact.join(' ')
  end
end
