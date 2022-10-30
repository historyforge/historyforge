# == Schema Information
#
# Table name: photographs
#
#  id             :bigint           not null, primary key
#  created_by_id  :bigint
#  building_id    :bigint
#  description    :text
#  creator        :string
#  date_text      :string
#  date_start     :date
#  date_end       :date
#  location       :string
#  identifier     :string
#  notes          :text
#  latitude       :decimal(, )
#  longitude      :decimal(, )
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  reviewed_by_id :bigint
#  reviewed_at    :datetime
#  date_type      :integer          default("year")
#  caption        :text
#
# Indexes
#
#  index_photographs_on_building_id     (building_id)
#  index_photographs_on_created_by_id   (created_by_id)
#  index_photographs_on_reviewed_by_id  (reviewed_by_id)
#

# frozen_string_literal: true

class Photograph < ApplicationRecord
  include PgSearch::Model
  include Flaggable
  include Moderation
  include Versioning

  has_and_belongs_to_many :buildings
  has_and_belongs_to_many :people
  has_one_attached :file

  alias_attribute :title, :caption
  alias_attribute :name, :caption

  attr_writer :date_year, :date_month, :date_day
  attr_writer :date_year_end, :date_month_end, :date_day_end

  enum date_type: %i[year month day years months days]

  before_validation :set_dates
  validates :file, attached: true, content_type: ['image/jpg', 'image/jpeg', 'image/png']

  pg_search_scope :full_text_search,
                  against: %i[caption location notes],
                  using: {
                      tsearch: { prefix: true, any_word: true }
                  }

  scope :unreviewed_only, ->(val) { val == '1' ? unreviewed : self }

  def self.ransackable_scopes(_auth_object=nil)
    %i{full_text_search unreviewed_only}
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
    set_date_from_years if year? || years?
    set_date_from_months if month? || months?
    set_date_from_days if day? || days?
  end

  private

  def set_date_from_days
    self.date_start = nil
    self.date_end = nil
    if date_year.present? && date_month.present? && date_day.present?
      self.date_start = Date.parse("#{date_year}-#{date_month.rjust(2, '0')}-#{date_day.rjust(2, '0')}")
    end
    return unless days? && date_year_end.present? && date_month_end.present? && date_day_end.present?

    self.date_end = Date.parse("#{date_year_end}-#{date_month_end.rjust(2, '0')}-#{date_day_end.rjust(2, '0')}")
  end

  def set_date_from_months
    self.date_start = nil
    self.date_end = nil
    if date_year.present? && date_month.present?
      self.date_start = Date.parse("#{date_year}-#{date_month.rjust(2, '0')}-01")
    end
    return unless months? && date_year_end.present? && date_month_end.present?

    self.date_end = Date.parse("#{date_year_end}-#{date_month_end.rjust(2, '0')}-01").end_of_month
  end

  def set_date_from_years
    self.date_start = nil
    self.date_end = nil
    self.date_start = Date.parse("#{date_year}-01-01") if date_year.present?
    self.date_end = Date.parse("#{date_year}-12-31") if years? && date_year_end.present?
  end
end
