# frozen_string_literal: true

class CensusFacet
  include FastMemoize

  def self.with_data_for(search, facet)
    data = new(search, facet)
    yield data.calculate
  end

  def initialize(search, facet)
    @search = search
    @facet = facet
  end

  class Facet
    include FastMemoize
    attr_reader :facet, :search

    def initialize(facet, search)
      @facet = facet
      @search = search
    end

    def charts
      %i[pie]
    end

    def sql
      search.scoped
            .reorder('1')
            .reselect("#{facet} AS facet, COUNT(id) AS value")
            .where("#{facet} IS NOT NULL")
            .group(facet)
            .to_sql
    end
    memoize :sql

    def query
      ActiveRecord::Base.connection.exec_query sql
    end
    memoize :query

    def rows
      query.map { |item| [item['facet'].presence || 'Blank', item['value']] }
    end
    memoize :rows

    def total
      query.map { |item| item['value'] }.reduce(&:+)
    end
    memoize :total
  end

  class BooleanFacet < Facet
    def rows
      query.map { |item| [item['facet'] == true ? 'Yes' : 'No', item['value']] }
    end
    memoize :rows
  end

  class EnumerationFacet < Facet
    def rows
      query.map { |item| [item['facet'].present? ? Translator.option(facet, item['facet'].to_s) : 'Blank', item['value']] }
    end
    memoize :rows
  end

  class SeriesFacet < Facet
    def charts
      %i[bar]
    end

    attr_accessor :from, :to, :step

    # Inspired by this: https://dba.stackexchange.com/questions/195664/aggregate-values-by-interval-range-given-by-parameter
    def sql
      values = search.scoped.reorder(nil).reselect("#{facet} AS facet_value")
      <<~SQL
        SELECT CONCAT(bucket, ' - ', bucket + #{step - 1}) AS facet, COUNT(facet_value) AS value
        FROM generate_series(#{from}, #{to}, #{step}) AS buckets(bucket)
        LEFT JOIN (#{values.to_sql}) AS records
          ON facet_value >= bucket AND facet_value < bucket + #{step}
        GROUP BY bucket
        ORDER BY bucket
      SQL
    end
    memoize :sql
  end

  class YearsFacet < SeriesFacet
    def from
      1800
    end

    def to
      2000
    end

    def step
      10
    end
  end

  class AgeFacet < SeriesFacet
    def from
      0
    end

    def to
      135
    end

    def step
      5
    end
  end

  def calculate

    generator_class = case type
                      when :boolean
                        BooleanFacet
                      when :integer
                        if facet == 'age'
                          AgeFacet
                        elsif facet =~ /year/
                          YearsFacet
                        else
                          Facet
                        end
                      when :radio_buttons, :radio_buttons_other
                        EnumerationFacet
                      else
                        Facet
                      end

    generator = generator_class.new(facet, search)
    {
      rows: generator.rows,
      total: generator.total,
      charts: generator.charts,
      explanation: options[:demographics_explanation]
    }
  end

  private

  attr_reader :search, :facet

  def options
    search.form_fields_config.options_for(facet.to_sym)
  end
  memoize :options

  def type
    options[:as]
  end
  memoize :type
end
