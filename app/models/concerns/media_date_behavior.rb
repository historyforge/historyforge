# frozen_string_literal: true

module MediaDateBehavior
  extend ActiveSupport::Concern
  included do
    attr_writer :date_year, :date_month, :date_day, :date_year_end, :date_month_end, :date_day_end

    enum :date_type, { year: 0, month: 1, day: 2, years: 3, months: 4, days: 5 }

    before_validation :set_dates

    scope :in_chronological_order, -> { order('date_start NULLS LAST') }
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
