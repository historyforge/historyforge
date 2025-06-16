module Api
  class SearchController < ApplicationController
    # "api/search?search=your_search"  provide your search as a query parameter called search like so
    # http://127.0.0.1:3000/api/search?search=#{params[:search]}
    ALLOWED_ORIGINS = %w[http://localhost:5173 http://localhost:5174 https://greenwood.jacrys.com https://jacrys.com].freeze

    def search_buildings(target, target_year)
      census_query     = ''
      building_query   = ''
      person_query     = ''
      audio_query      = ''
      video_query      = ''
      documents_query  = ''
      photo_query      = ''
      narrative_query  = ''
      rich_text_query  = ''
      address_query    = ''

      census_query     = search_query("Census#{target_year}Record", census_query)
      building_query   = search_query('Building', building_query)
      person_query     = search_query('Person', person_query)
      audio_query      = search_query('Audio', audio_query)
      video_query      = search_query('Video', video_query)
      photo_query      = search_query('Photograph', photo_query)
      narrative_query  = search_query('Narrative', narrative_query)
      rich_text_query  = search_query('ActionText::RichText', rich_text_query)
      address_query    = search_query('Address', address_query)
      documents_query  = search_query('Document', documents_query)

      building_query   = building_query.chomp('OR ')
      census_query     = census_query.chomp('OR ')
      person_query     = person_query.chomp('OR ')
      audio_query      = audio_query.chomp('OR ')
      video_query      = video_query.chomp('OR ')
      photo_query      = photo_query.chomp('OR ')
      narrative_query  = narrative_query.chomp('OR ')
      rich_text_query  = rich_text_query.chomp('OR ')
      address_query    = address_query.chomp('OR ')
      documents_query  = documents_query.chomp('OR ')

      if target.present?
        buildings = Building.where(building_query, search: "%#{target}%").ids.uniq
        building_photo = Building.joins(:photos).where('Photographs.searchable_text::varchar ILIKE :search', search: "%#{target}%").ids.uniq
        building_video = Building.joins(:videos).where('Videos.searchable_text::varchar ILIKE :search', search: "%#{target}%").ids.uniq
        building_audio = Building.joins(:audios).where('Audios.searchable_text::varchar ILIKE :search', search: "%#{target}%").ids.uniq
        building_narrative = Building.joins(:narratives).where(narrative_query, search: "%#{target}%").ids.uniq
        building_action_text_story = Building.joins(narratives: :rich_text_story).where(rich_text_query, search: "%#{target}%").ids.uniq
        building_action_text_sources = Building.joins(narratives: :rich_text_sources).where(rich_text_query, search: "%#{target}%").ids.uniq
        building_action_text_description = Building.joins(:rich_text_description).where(rich_text_query, search: "%#{target}%").ids.uniq
        building_address = Building.joins(:addresses).where(address_query, search: "%#{target}%").ids.uniq

        census_record_year = :"census#{target_year}_records"
        people_year = :"people_#{target_year}"

        buildings_census = Building.joins(census_record_year).where(census_query, search: "%#{target}%").ids.uniq
        buildings_people = Building.joins(people_year).where(person_query, search: "%#{target}%").ids.uniq

        people_photo = Building.joins({ people_year => :photos }).where('photographs.searchable_text::varchar ILIKE ?', "%#{target}%").distinct.ids
        people_video = Building.joins({ people_year =>  :videos }).where('Videos.searchable_text::varchar ILIKE :search', search: "%#{target}%").ids.uniq
        people_audio = Building.joins({ people_year => :audios }).where('Audios.searchable_text::varchar ILIKE :search', search: "%#{target}%").ids.uniq
        people_narrative = Building.joins({ people_year => :narratives }).where(narrative_query, search: "%#{target}%").ids.uniq
        people_document = Building.joins({ people_year => :documents }).where(documents_query, search: "%#{target}%").ids.uniq

        narrative_action_text_story = Building.joins({ people_year => [{ narratives: :rich_text_story }] }).where(rich_text_query, search: "%#{target}%").ids.uniq
        narrative_action_text_sources = Building.joins({ people_year => [{ narratives: :rich_text_sources }] }).where(rich_text_query, search: "%#{target}%").ids.uniq

        buildings << building_photo
        buildings << building_video
        buildings << building_audio
        buildings << building_narrative
        buildings << building_action_text_sources
        buildings << building_action_text_story
        buildings << building_action_text_description
        buildings << building_address

        buildings << buildings_census
        buildings << buildings_people
        buildings << people_photo
        buildings << people_video
        buildings << people_audio
        buildings << people_narrative
        buildings << people_document

        buildings << narrative_action_text_story
        buildings << narrative_action_text_sources

        buildings = buildings.flatten.uniq
        buildings = Building.where(id: buildings)
      else
        buildings = Building.all
      end
      buildings
    end

    private def search_query(class_name, chosen_query)
      class_object = class_name.constantize
      table_name = class_object.table_name
      class_object.column_names.each do |name|
        query = "#{table_name}.#{name}::varchar ILIKE :search OR "
        chosen_query = chosen_query.concat(query)
      end
      chosen_query
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
      list_years = %w[1910 1920]
      list_years.each do |year|
        buildings = search_buildings(params['search'], year)
        buildings = buildings.includes(
          :narratives, :photos, :audios, :videos, :addresses,
          :"people_#{year}", :"census#{year}_records"
        )
        features = buildings.filter_map { |building| make_feature(building, year) }
        all_features.concat(features).flatten
      end

      geojson = Building.as_geojson(all_features)

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
          data_uri:
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
          data_uri:
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
          data_uri:
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
          properties: [people: document.people.uniq],
          data_uri:
        }
      end

      # Only return the feature if there are any census records for this year
      return if census_records.empty?

      record.instance_variable_set(:@census_records, census_records)
      record.instance_variable_set(:@people, people)
      record.narratives = building_narratives
      record.photos = building_photos
      record.audios = building_audios
      record.videos = building_videos
      record.documents = building_documents

      record
    end
  end
end
