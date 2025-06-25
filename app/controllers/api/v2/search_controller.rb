module Api
  module V2
    class SearchController < ApplicationController
      protect_from_forgery with: :null_session, if: :cors_request?

      SEARCH_YEARS = %w[1910 1920].freeze

      def search

        if request.method == 'OPTIONS'
          set_cors_headers
          head :ok
          return
        end

        # CORS validation
        # validate_origin!

        search_term = params[:search]
        return render_empty_geojson if search_term.blank?

        # Build features for each year exactly like v1
        all_features = []
        list_years = %w[1910 1920]

        list_years.each do |year|
          buildings = search_buildings(search_term, year)

          buildings = buildings.includes(
            :narratives, :photos, :audios, :videos, :addresses,
            :"people_#{year}", :"census#{year}_records"
          )

          features = buildings.filter_map { |building| make_feature(building, year) }
          all_features.concat(features).flatten
        end

        geojson = Building.as_geojson(all_features)

        # Set CORS headers
        # origin = request.headers['Origin']
        # response_headers = if origin.nil?
        #                      { 'Access-Control-Allow-Origin' => 'localhost' }
        #                    else
        #                      { 'Access-Control-Allow-Origin' => origin }
        #                    end
        # response_headers['Vary'] = 'Origin'
        response_headers = { 'Access-Control-Allow-Origin' => '*' }
        response_headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
        response_headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization, X-Requested-With'
        response_headers['Vary'] = 'Origin'
        response.headers.merge!(response_headers)

        render json: geojson
      end

      private

      # def set_cors_headers
      #   origin = request.headers['Origin']

      #   # if origin.nil? || ALLOWED_ORIGINS.include?(origin) || origin.start_with?('http://localhost:', 'https://localhost:')
      #     # response.headers['Access-Control-Allow-Origin'] = origin
      #   # elsif ALLOWED_ORIGINS.include?(host)
      #   response.headers['Access-Control-Allow-Origin'] = '*'
      #   # end

      #   response.headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
      #   response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization, X-Requested-With'
      #   response.headers['Vary'] = 'Origin'

      # end

      def strict_mode?
        # Default to true (strict) unless explicitly set to false
        params[:strict] != 'false'
      end

      # def validate_origin!
      #   origin = request.headers['Origin']
      #   ua = request.headers['User-Agent']
      #   host = request.host

      #   return if origin_allowed?(origin, host, ua)

      #   render status: :forbidden, plain: 'Forbidden'
      # end

      # def origin_allowed?(origin, host, ua)
      #   return true if origin.nil? && ua.include?('PostmanRuntime')
      #   return true if ALLOWED_ORIGINS.include?(origin)
      #   # Simplified localhost check
      #   return true if origin&.start_with?('http://localhost:', 'https://localhost:')

      #   # Check for greenwood domains
      #   return true if origin&.include?('greenwood')

      #   false
      # end

      def render_empty_geojson
        render json: { type: 'FeatureCollection', features: [] }
      end

      def search_buildings(target, target_year)
        # Use v1's exact search logic: find IDs first, then load with includes
        building_ids = search_buildings_for_year(target, target_year)

        return Building.none if building_ids.empty?

        # Load buildings with all necessary includes for the specific year
        Building.where(id: building_ids)
      end

      def search_buildings_for_year(target, year)
        search_pattern = "%#{target}%"
        building_ids = []

        # Use v1's search approach - collect all building IDs that match

        # Direct building fields
        building_ids.concat(
          Building.where('buildings.name ILIKE ? OR buildings.description ILIKE ?',
                         search_pattern, search_pattern)
                  .where('lat IS NOT NULL AND lon IS NOT NULL').pluck(:id)
        )

        # Building associations
        building_ids.concat(
          Building.joins(:addresses)
                  .where('addresses.searchable_text ILIKE ?', search_pattern)
                  .where('lat IS NOT NULL AND lon IS NOT NULL')
                  .pluck(:id)
        )

        building_ids.concat(
          Building.joins(:photos)
                  .where('photographs.searchable_text ILIKE ?', search_pattern)
                  .where('lat IS NOT NULL AND lon IS NOT NULL')
                  .pluck(:id)
        )

        building_ids.concat(
          Building.joins(:videos)
                  .where('videos.searchable_text ILIKE ?', search_pattern)
                  .where('lat IS NOT NULL AND lon IS NOT NULL')
                  .pluck(:id)
        )

        building_ids.concat(
          Building.joins(:audios)
                  .where('audios.searchable_text ILIKE ?', search_pattern)
                  .where('lat IS NOT NULL AND lon IS NOT NULL')
                  .pluck(:id)
        )

        building_ids.concat(
          Building.joins(:narratives)
                  .where('narratives.source ILIKE ? OR narratives.notes ILIKE ?',
                         search_pattern, search_pattern)
                  .where('lat IS NOT NULL AND lon IS NOT NULL')
                  .pluck(:id)
        )

        # Rich text searches
        building_ids.concat(
          Building.joins(:rich_text_description)
                  .where('action_text_rich_texts.body ILIKE ?', search_pattern)
                  .where('lat IS NOT NULL AND lon IS NOT NULL')
                  .pluck(:id)
        )

        # Census and people for specific year
        people_association = :"people_#{year}"
        building_ids.concat(
          Building.joins(people_association)
                  .where('people.searchable_name ILIKE ?',
                         search_pattern)
                  .where('lat IS NOT NULL AND lon IS NOT NULL')
                  .pluck(:id)
        )

        census_association = :"census#{year}_records"
        census_table_association = "census_#{year}_records"
        building_ids.concat(
          Building.joins(census_association)
                  .where("#{census_table_association}.searchable_name ILIKE ?",
                         search_pattern)
                  .where('lat IS NOT NULL AND lon IS NOT NULL')
                  .pluck(:id)
        )

        building_ids.uniq
      end

      def make_feature(building, year)
        return nil unless building&.latitude&.nonzero? && building&.longitude&.nonzero?

        # Apply strict mode filtering like v1
        if strict_mode?
          case year
          when '1910'
            return nil unless building.people_1910.any? || building.census1910_records.any?
          when '1920'
            return nil unless building.people_1920.any? || building.census1920_records.any?
          end
        end

        people_method = :"people_#{year}"
        census_method = :"census#{year}_records"

        # Use same logic as v1 - get people/census data for the building
        people = building.send(people_method) || []
        census_records = building.send(census_method) || []

        # Collect building narratives
        building_narratives = building.narratives.map do |narrative|
          { record: narrative, sources: narrative.sources, story: narrative.story }
        end

        # Collect building photos
        building_photos = building.photos.map do |photo|
          {
            id: photo.id,
            type: 'photo',
            description: photo.description,
            caption: photo.caption,
            attatchment: photo.file_attachment,
            URL: sanitize_url(rails_blob_url(photo.file_attachment, host: ENV.fetch('BASE_URL', nil))),
            properties: {buildings: photo.buildings, people: photo.people},
            data_uri: photo.data_uri
          }
        end

        # Collect building audios
        building_audios = building.audios.map do |audio|
          {
            id: audio.id,
            type: 'audio',
            description: audio.description,
            caption: audio.caption,
            URL: audio.remote_url,
            properties: {buildings: audio.buildings, people: audio.people},
            data_uri: audio.data_uri
          }
        end

        # Collect building videos
        building_videos = building.videos.map do |video|
          {
            id: video.id,
            type: 'video',
            description: video.description,
            caption: video.caption,
            URL: video.remote_url,
            properties: {buildings: video.buildings, people: video.people},
            data_uri: video.data_uri
          }
        end

        # Collect building documents
        building_documents = building.documents.map do |document|
          {
            id: document.id,
            category: document.document_category.name,
            name: document.name,
            description: document.description,
            URL: document.file_attachment.present? ? sanitize_url(rails_blob_url(document.file_attachment, host: ENV.fetch('BASE_URL', nil))) : nil,
            properties: [people: document.people.uniq],
            data_uri: document.data_uri
          }
        end

        # Set up instance variables exactly like v1
        building.instance_variable_set(:@census_records, census_records)
        building.instance_variable_set(:@people, people)
        building.instance_variable_set(:@year, year)
        building.instance_variable_set(:@building_narratives, building_narratives)
        building.instance_variable_set(:@building_photos, building_photos)
        building.instance_variable_set(:@building_audios, building_audios)
        building.instance_variable_set(:@building_videos, building_videos)
        building.instance_variable_set(:@building_documents, building_documents)

        # Set up singleton methods exactly like v1
        building.define_singleton_method(:building_people) { people }
        building.define_singleton_method(:building_census) { census_records }
        building.define_singleton_method(:year) { year }
        building.define_singleton_method(:building_narratives) { building_narratives }
        building.define_singleton_method(:building_photos) { building_photos }
        building.define_singleton_method(:building_audios) { building_audios }
        building.define_singleton_method(:building_videos) { building_videos }
        building.define_singleton_method(:building_documents) { building_documents }

        building
      end

      def sanitize_url(url)
        return nil if url.blank?

        # Remove double admin
        url.gsub('/admin/admin/', '/admin/')
      end

      def cors_request?
        origin = request.headers['Origin']
        allowed_origins = Rails.application.config.allowed_cors_origins
        origin.present? && allowed_origins.include?(origin)
      end

      def set_cors_headers
        origin = request.headers['Origin']
        allowed_origins = Rails.application.config.allowed_cors_origins

        if origin.present? && (allowed_origins.include?(origin) || allowed_origins.include?('*'))
          response.headers['Access-Control-Allow-Origin'] = origin
        elsif allowed_origins.include?('*')
          response.headers['Access-Control-Allow-Origin'] = '*'
        end

        response.headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
        response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization, X-Requested-With'
      end
    end
  end
end
