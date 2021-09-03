class CensusFacet
  include Memery

  def self.with_data_for(search, facet)
    data = new(search, facet)
    yield data.calculate
  end

  def initialize(search, facet)
    @search = search
    @facet = facet
  end

  class Facet
    include Memery
    attr_reader :facet, :search

    def initialize(facet, search)
      @facet = facet
      @search = search
    end

    def charts
      %i[pie bar]
    end

    memoize def sql
      search.scoped
            .reorder('1')
            .reselect("#{facet} AS facet, COUNT(id) AS value")
            .where("#{facet} IS NOT NULL")
            .group(facet)
            .to_sql
    end

    memoize def query
      Rails.logger.info sql.inspect
      ActiveRecord::Base.connection.exec_query sql
    end

    memoize def rows
      query.map { |item| [item['facet'].presence || 'Blank', item['value']] }
    end

    memoize def total
      query.map { |item| item['value'] }.reduce(&:+)
    end
  end

  class BooleanFacet < Facet
    memoize def rows
      query.map { |item| [item['facet'] == true ? 'Yes' : 'No', item['value']] }
    end
  end

  class EnumerationFacet < Facet
    memoize def rows
      query.map { |item| [item['facet'].present? ? Translator.option(facet, item['facet'].to_s) : 'Blank', item['value']] }
    end
  end

  class SeriesFacet < Facet
    def charts
      %i[bar]
    end

    attr_accessor :from, :to, :step

    # Inspired by this: https://dba.stackexchange.com/questions/195664/aggregate-values-by-interval-range-given-by-parameter
    memoize def sql
      snippet = "WITH CTS AS ( SELECT generate_series(#{from}, #{to}, #{step} ) Serie )"
      from = "CTS LEFT JOIN #{search.entity_class.table_name} ON #{facet} >= CTS.Serie AND #{facet} <= CTS.Serie + #{step}"
      base = search.scoped
                   .from(from)
                   .reorder('CTS.Serie')
                   .reselect("COALESCE(COUNT(#{facet}), 0) AS value, CONCAT(Serie, ' - ', Serie + #{step - 1}) as facet")
                   .group("CTS.Serie")
                   .where("#{facet} IS NOT NULL")
      "#{snippet} #{base.to_sql}"
    end
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
      charts: generator.charts
    }
  end

  private

  attr_reader :search, :facet

  memoize def options
    search.form_fields_config.options_for(facet.intern)
  end

  memoize def type
    options[:as]
  end
end
