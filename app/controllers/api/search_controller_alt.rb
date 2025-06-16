module Api
  class SearchController < ApplicationController
    # "api/search?search=your_search"  provide your search as a query parameter called search like so
    # http://127.0.0.1:3000/api/search?search=#{params[:search]}
    ALLOWED_ORIGINS = %w[http://localhost:5173 http://localhost:5174 https://greenwood.jacrys.com https://jacrys.com].freeze

    def search_buildings(target, target_year)
      building_query   = ''
      building_query   = search_query('Building', building_query)

      building_query   = building_query.chomp('OR ')

      if target.present?

        Building.where(building_query, search: "%#{target}%")
                .includes(:narratives, :photos, :audios, :videos, :addresses,
                          :"people_#{target_year}", :"census#{target_year}_records")
                .distinct
      else
        Building.all
      end
    end

    def search
      rq = {
        origin: request.headers['Origin'],
        host: request.host
      }
      if ALLOWED_ORIGINS.include?(rq[:origin]) || (rq[:host] == 'localhost' && rq[:origin].nil?)
        response_headers = if rq[:origin].nil?
                             { 'Access-Control-Allow-Origin' => 'localhost' }
                           else
                             { 'Access-Control-Allow-Origin' => rq[:origin] }
                           end
      else
        # Handle requests from disallowed origins (e.g., return a 403 Forbidden or omit the header)
        response_headers = {} # or {"Access-Control-Allow-Origin" => "null"} (use with caution)
        render status: :forbidden, plain: 'Forbidden' and return
      end
      response_headers['Vary'] = 'Origin' # Include Vary: Origin

      all_features = []
      list_years   = %w[1910 1920]
      list_years.each do |year|
        buildings = search_buildings(params['search'], year)
        features = buildings.filter_map { |building| make_feature(building, year) }
        all_features.concat(features)
      end

      geojson = build_geojson(all_features)

      response.headers.merge!(response_headers)
      render json: geojson
    end

    def make_feature(record, year)
      census_records = record.respond_to?("census#{year}_records") ? record.send("census#{year}_records") : []
      people = record.respond_to?("people_#{year}") ? record.send("people_#{year}") : []

      # Collect building narratives
      building_narratives = record.narratives.map do |narrative|
        { record: narrative, sources: narrative.sources, story: narrative.story }
      end

      # Collect building photos
      building_photos = record.photos.map do |photo|
        {
          id: photo.id,
          type: 'photo',
          description: photo.description,
          caption: photo.caption,
          attatchment: photo.file_attachment,
          URL: sanitize_url(rails_blob_url(photo.file_attachment, only_path: true)),
          properties: [buildings: photo.buildings, people: photo.people],
          data: Base64Encoder.encode_active_storage_file(photo.file_attachment)
        }
      end

      # Collect building audios
      building_audios = record.audios.map do |audio|
        {
          id: audio.id,
          type: 'audio',
          description: audio.description,
          caption: audio.caption,
          URL: audio.remote_url,
          properties: [buildings: audio.buildings, people: audio.people],
          data: Base64Encoder.encode_url_file(audio.remote_url)
        }
      end

      # Collect building videos
      building_videos = record.videos.map do |video|
        {
          id: video.id,
          type: 'video',
          description: video.description,
          caption: video.caption,
          URL: video.remote_url,
          properties: [buildings: video.buildings, people: video.people],
          data: Base64Encoder.encode_url_file(record.remote_url)
        }
      end

      # Collect building documents
      building_documents = record.documents.map do |document|
        {
          id: document.id,
          category: document.document_category.name,
          name: document.name,
          description: document.description,
          URL: sanitize_url(rails_blob_url(document.file_attachment, only_path: true)),
          properties: [people: document.people],
          data: Base64Encoder.encode_active_storage_file(document.file_attachment)
        }
      end

      # Only return the feature if there are any census records for this year
      return if census_records.empty?

      {
        type: 'Feature',
        geometry: {
          type: 'Point',
          coordinates: record.coordinates
        },
        properties: {
          location_id: record.id,
          title: record.primary_street_address,
          year:,
          addresses: record.addresses,
          audios: building_audios,
          narratives: building_narratives,
          videos: building_videos,
          photos: building_photos,
          documents: building_documents,
          description: record.full_street_address,
          rich_description: record.rich_text_description,
          census_records: census_records.map(&:as_json),
          people: people.map(&:as_json)
        }
      }
    end

    private

    def search_query(class_name, chosen_query)
      class_object = class_name.constantize
      table_name = class_object.table_name
      class_object.column_names.each do |name|
        query = "#{table_name}.#{name}::varchar ILIKE :search OR "
        chosen_query.concat(query)
      end
      chosen_query
    end

    def build_geojson(features)
      {
        type: 'FeatureCollection',
        features:
      }
    end
  end
end
