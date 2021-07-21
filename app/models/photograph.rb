class Photograph < ApplicationRecord
  include PgSearch::Model
  include Flaggable
  include Moderation

  has_and_belongs_to_many :buildings
  has_and_belongs_to_many :people
  belongs_to :physical_type, optional: true
  belongs_to :physical_format, optional: true
  belongs_to :rights_statement, optional: true
  has_one_attached :file

  alias_attribute :name, :title

  attr_writer :date_year, :date_month, :date_day
  attr_writer :date_year_end, :date_month_end, :date_day_end

  enum date_type: %i[year month day years months days]

  before_validation :set_dates
  validates :title, :description, :physical_type_id, :physical_format_id, :rights_statement_id, presence: true, if: :reviewed?
  validates :file, attached: true, content_type: ['image/jpg', 'image/jpeg', 'image/png']

  pg_search_scope :full_text_search,
                  against: %i[title description creator subject location physical_description notes],
                  using: {
                      tsearch: { prefix: true, any_word: true }
                  }

  def self.ransackable_scopes(auth_object=nil)
    %i{full_text_search unreviewed}
  end

  def full_caption
    items = [caption]
    items << date_text if date_text?
    items.compact.join(' ')
  end

  def date_year
    @date_year ||= date_start&.year
  end

  def date_month
    @date_month ||= date_start&.month
  end

  def date_day
    @date_day ||= date_start&.day
  end

  def date_year_end
    @date_year_end ||= date_end&.year
  end

  def date_month_end
    @date_month_end ||= date_end&.month
  end

  def date_day_end
    @date_day_end ||= date_end&.day
  end

  def set_dates
    if year? || years?
      self.date_start = nil
      self.date_end = nil
      self.date_start = Date.parse("#{date_year}-01-01") if date_year.present?
      self.date_end = Date.parse("#{date_year}-12-31") if years? && date_year_end.present?
    end
    if month? || months?
      self.date_start = nil
      self.date_end = nil
      self.date_start = Date.parse("#{date_year}-#{date_month.rjust(2, '0')}-01") if date_year.present? && date_month.present?
      self.date_end = Date.parse("#{date_year_end}-#{date_month_end.rjust(2, '0')}-01").end_of_month if months? && date_year_end.present? && date_month_end.present?
    end
    if day? || days?
      self.date_start = nil
      self.date_end = nil
      self.date_start = Date.parse("#{date_year}-#{date_month.rjust(2, '0')}-#{date_day.rjust(2, '0')}") if date_year.present? && date_month.present? && date_day.present?
      self.date_end = Date.parse("#{date_year_end}-#{date_month_end.rjust(2, '0')}-#{date_day_end.rjust(2, '0')}") if days? && date_year_end.present? && date_month_end.present? && date_day_end.present?
    end
  end
end
