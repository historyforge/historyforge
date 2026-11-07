# frozen_string_literal: true

module People
  class Sitemap
    NAMESPACE = 'http://www.sitemaps.org/schemas/sitemap/0.9'
    SHARD_SIZE = 50_000
    MAX_PERSON_ID = 2**31 - 1
    CACHE_TTL = 15.minutes

    def initialize(url_options:)
      @routes = Rails.application.routes.url_helpers
      @url_options = url_options.merge(PublicUrlOptions.call)
    end

    def index
      cached('index') do
        next_id = Person.where(id: 1..).minimum(:id)
        next unless next_id

        build_xml(:sitemapindex) do |xml|
          while next_id
            shard = (next_id - 1) / SHARD_SIZE
            xml.sitemap { xml.loc @routes.people_sitemap_url(shard:, **@url_options) }
            upper_id = (shard + 1) * SHARD_SIZE
            next_id = upper_id < MAX_PERSON_ID ? Person.where('id > ?', upper_id).minimum(:id) : nil
          end
        end
      end
    end

    def people(shard)
      return if shard > (MAX_PERSON_ID - 1) / SHARD_SIZE

      years = CensusYears.visible_to_user(nil)
      cached('people', shard, years) do
        range = (shard * SHARD_SIZE + 1)..[(shard + 1) * SHARD_SIZE, MAX_PERSON_ID].min
        people = Person.where(id: range).order(:id).pluck(:id, :updated_at)
        next if people.empty?

        last_modified = census_last_modified(range, years)
        build_xml(:urlset) do |xml|
          people.each do |id, updated_at|
            xml.url do
              xml.loc @routes.person_url(id, **@url_options)
              date = [updated_at, last_modified[id]].compact.max
              xml.lastmod date.utc.iso8601 if date
            end
          end
        end
      end
    end

    private

    def census_last_modified(range, years)
      public_ability = Ability.new(nil)
      years.each_with_object({}) do |year, dates|
        CensusRecord.for_year(year).accessible_by(public_ability, :read).where(person_id: range).group(:person_id)
                    .maximum(Arel.sql('GREATEST(updated_at, reviewed_at)')).each do |id, date|
          dates[id] = [dates[id], date].compact.max
        end
      end
    end

    def cached(*parts, &block)
      database = Person.connection_db_config.configuration_hash.values_at(:host, :port, :database)
      key = ['person-sitemap-v1', database, @routes.sitemap_url(**@url_options), *parts]
      Rails.cache.fetch(key, expires_in: CACHE_TTL, skip_nil: true, &block)
    end

    def build_xml(root)
      Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.public_send(root, xmlns: NAMESPACE) { yield xml }
      end.to_xml
    end
  end
end
