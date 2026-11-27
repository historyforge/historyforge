# frozen_string_literal: true

class OperatorCensusActivity
  RECENT_LIMIT = 10

  def initialize(years:, locality_id:)
    @records_by_year = years.index_with do |year|
      records = CensusYears.class_for(year).all
      locality_id ? records.where(locality_id:) : records
    end
  end

  def counts_for(creator)
    @records_by_year.each_with_object({}) do |(year, records), counts|
      count = records.where(created_by_id: creator.id).count
      counts[year] = count if count.positive?
    end
  end

  def recent_operators
    latest = {}
    @records_by_year.each_value do |records|
      by_creator = records.where.not(created_by_id: nil).group(:created_by_id)
                          .order(Arel.sql('MAX(created_at) DESC'), :created_by_id)
                          .limit(RECENT_LIMIT).maximum(:created_at)
      latest.merge!(by_creator) { |_id, previous, current| [previous, current].max }
    end

    ranked = latest.sort_by { |id, time| [-time.to_r, id] }.first(RECENT_LIMIT)
    operators = User.where(id: ranked.map(&:first)).index_by(&:id)
    ranked.filter_map { |id, time| [operators[id], time] if operators.key?(id) }
  end
end
