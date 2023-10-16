# frozen_string_literal: true

class CensusStats
  def census_summaries
    @census_summaries ||= CensusYears.map do |year|
      klass = "Census#{year}Record".constantize
      { year:, total: klass.count, reviewed: klass.reviewed.count }
    end
  end

  def recent_census_summaries
    @recent_census_summaries ||= CensusYears.map do |year|
      klass = "Census#{year}Record".constantize
      { year:, total: klass.recently_added.count, reviewed: klass.recently_reviewed.count }
    end
  end

  def overall_heroes
    @overall_heroes ||= Census1900Record.find_by_sql("SELECT users.login, COUNT(census_records.id) AS total FROM (
      SELECT id, created_by_id FROM census_1850_records
      UNION SELECT id, created_by_id FROM census_1860_records
      UNION SELECT id, created_by_id FROM census_1870_records
      UNION SELECT id, created_by_id FROM census_1880_records
      UNION SELECT id, created_by_id FROM census_1900_records
      UNION SELECT id, created_by_id FROM census_1910_records
      UNION SELECT id, created_by_id FROM census_1920_records
      UNION SELECT id, created_by_id FROM census_1930_records
      UNION SELECT id, created_by_id FROM census_1940_records
      UNION SELECT id, created_by_id FROM census_1950_records
    ) census_records INNER JOIN users ON census_records.created_by_id=users.id
    GROUP BY users.login ORDER BY total DESC LIMIT 10")
  end

  def recent_heroes
    @recent_heroes ||= Census1900Record.find_by_sql(["SELECT users.login, COUNT(census_records.id) AS total FROM (
      SELECT id, created_by_id FROM census_1850_records WHERE created_at>=:date
      UNION SELECT id, created_by_id FROM census_1860_records WHERE created_at>=:date
      UNION SELECT id, created_by_id FROM census_1870_records WHERE created_at>=:date
      UNION SELECT id, created_by_id FROM census_1880_records WHERE created_at>=:date
      UNION SELECT id, created_by_id FROM census_1900_records WHERE created_at>=:date
      UNION SELECT id, created_by_id FROM census_1910_records WHERE created_at>=:date
      UNION SELECT id, created_by_id FROM census_1920_records WHERE created_at>=:date
      UNION SELECT id, created_by_id FROM census_1930_records WHERE created_at>=:date
      UNION SELECT id, created_by_id FROM census_1940_records WHERE created_at>=:date
      UNION SELECT id, created_by_id FROM census_1950_records WHERE created_at>=:date
    ) census_records INNER JOIN users ON census_records.created_by_id=users.id
    GROUP BY users.login ORDER BY total DESC LIMIT 10", { date: 3.months.ago }])
  end
end
