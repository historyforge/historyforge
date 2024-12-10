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

    alias_attribute :title, :caption
    alias_attribute :name, :caption

    before_save :generate_searchable_text

    # TODO: Create a ts_vector column, hard to deploy because it requires
    #   creating a trigger, and the Dokku postgres app user does not have
    #   the required privileges. Maybe after migrating to DB cluster?
    pg_search_scope :full_text_search,
                    against: :searchable_text,
                    using: {
                      tsearch: { prefix: true }
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

  def process
    # implemented by interested subclasses
  end

  def generate_searchable_text
    self.searchable_text = [
      caption,
      location,
      notes,
      *people.map(&:name),
      *people.flat_map { _1.variant_names.map(&:name) },
      *buildings.map(&:name),
      *buildings.flat_map { _1.addresses.map(&:address) }
    ].join(' | ')
  end
end
