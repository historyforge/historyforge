class CensusStats
  def census_summaries
    @census_summaries ||= [
      { year: 1900, total: Census1900Record.count, reviewed: Census1900Record.reviewed.count },
      { year: 1910, total: Census1910Record.count, reviewed: Census1910Record.reviewed.count },
      { year: 1920, total: Census1920Record.count, reviewed: Census1920Record.reviewed.count },
      { year: 1930, total: Census1930Record.count, reviewed: Census1930Record.reviewed.count },
      { year: 1940, total: Census1940Record.count, reviewed: Census1940Record.reviewed.count }
    ]
  end

  def recent_census_summaries
    @recent_census_summaries ||= [
      { year: 1900, total: Census1900Record.recently_added.count, reviewed: Census1900Record.recently_reviewed.count },
      { year: 1910, total: Census1910Record.recently_added.count, reviewed: Census1910Record.recently_reviewed.count },
      { year: 1920, total: Census1920Record.recently_added.count, reviewed: Census1920Record.recently_reviewed.count },
      { year: 1930, total: Census1930Record.recently_added.count, reviewed: Census1930Record.recently_reviewed.count },
      { year: 1940, total: Census1940Record.recently_added.count, reviewed: Census1940Record.recently_reviewed.count }
    ]
  end

  def overall_heroes
    @overall_heroes ||= Census1900Record.find_by_sql("SELECT users.login, COUNT(census_records.id) AS total FROM (
      SELECT id, created_by_id FROM census_1900_records
      UNION SELECT id, created_by_id FROM census_1910_records
      UNION SELECT id, created_by_id FROM census_1920_records
      UNION SELECT id, created_by_id FROM census_1930_records
      UNION SELECT id, created_by_id FROM census_1940_records
    ) census_records INNER JOIN users ON census_records.created_by_id=users.id
    GROUP BY users.login ORDER BY total DESC LIMIT 10")
  end

  def recent_heroes
    @recent_heroes ||= Census1900Record.find_by_sql(["SELECT users.login, COUNT(census_records.id) AS total FROM (
      SELECT id, created_by_id FROM census_1900_records WHERE created_at>=:date
      UNION SELECT id, created_by_id FROM census_1910_records WHERE created_at>=:date
      UNION SELECT id, created_by_id FROM census_1920_records WHERE created_at>=:date
      UNION SELECT id, created_by_id FROM census_1930_records WHERE created_at>=:date
      UNION SELECT id, created_by_id FROM census_1940_records WHERE created_at>=:date
    ) census_records INNER JOIN users ON census_records.created_by_id=users.id
    GROUP BY users.login ORDER BY total DESC LIMIT 10", { date: 3.months.ago }])
  end
end
