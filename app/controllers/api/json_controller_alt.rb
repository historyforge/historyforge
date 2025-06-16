module Api
  class JsonController < ApplicationController
    # "api/json?search=your_search" provide your search as a query parameter called search like so
    # http://127.0.0.1:3000/api/json?search=#{params[:search]}
    @@search_controller = SearchController.new
    ALLOWED_ORIGINS = %w[http://localhost:5173 http://localhost:5174 https://greenwood.jacrys.com https://jacrys.com].freeze

    def json
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
        response_headers = {} # or {"Access-Control-Allow-Origin": "null"} (use with caution)
        render status: :forbidden, plain: 'Forbidden' and return
      end
      response_headers['Vary'] = 'Origin' # Include Vary: Origin

      all_buildings = []
      all_people = []
      all_documents = []
      all_stories = []
      all_media = []
      counts = []
      @final_buildings = 0
      @final_people = 0
      @final_documents = 0
      @final_census_records = 0
      @final_stories = 0
      @final_media = 0
      list_years = %w[1910 1920]

      list_years.each do |list_year|
        @buildings = @@search_controller.search_buildings(params['search'], list_year)
        @buildings = @buildings.includes(
          :narratives, :photos, :audios, :videos, :addresses,
          :"people_#{list_year}", :"census#{list_year}_records"
        )
        @ready_buildings = @buildings.filter_map { |b| make_building(b, list_year)&.merge(year: list_year) }
        all_buildings.concat(@ready_buildings)

        @people = search_people(params['search'], list_year)
        if @people.present?
          @people = @people.includes(
            :photos, :audios, :videos, :narratives, :buildings,
            :"census#{list_year}_records"
          )
        end
        @ready_people = @people.filter_map { |p| make_person(p, list_year)&.merge(year: list_year) }
        all_people.concat(@ready_people)

        @documents = search_documents(params['search'])
        @documents = @documents.includes(:people, :document_category, :file_attachment) if @documents.present?
        @ready_documents = @documents.filter_map { |d| make_document(d, list_year)&.merge(year: list_year) }
        all_documents.concat(@ready_documents)

        @videos = search_videos(params['search'])
        @videos = @videos.includes(:buildings, :people) if @videos.present?
        @audios = search_audios(params['search'])
        @audios = @audios.includes(:buildings, :people) if @audios.present?
        @photos = search_photos(params['search'])
        @photos = @photos.includes(:buildings, :people, :file_attachment) if @photos.present?

        @ready_videos = @videos&.map { |v| make_video(v, list_year)&.merge(year: list_year) }&.compact_blank || []
        @ready_audios = @audios&.map { |a| make_audio(a, list_year)&.merge(year: list_year) }&.compact_blank || []
        @ready_photos = @photos&.map { |p| make_photo(p, list_year)&.merge(year: list_year) }&.compact_blank || []
        @ready_media = @ready_videos + @ready_audios + @ready_photos
        all_media.concat(@ready_media)

        @narratives = search_narratives(params['search'])
        @ready_narratives = @narratives.filter_map { |n| make_narrative(n, list_year)&.merge(year: list_year) }
        all_stories.concat(@ready_narratives)

        # Count logic
        census_records = 0
        census_record_names = %w[census record census census records]
        @ready_documents.each do |doc|
          census_records += 1 if doc[:category] && census_record_names.include?(doc[:category].downcase)
        end

        counts << {
          buildings: @ready_buildings.count,
          people: @ready_people.count,
          documents: @ready_documents.count,
          census_records: census_records,
          stories: @ready_narratives.count,
          media: @ready_media.count,
          year: list_year
        }

        @final_buildings += @ready_buildings.count
        @final_people += @ready_people.count
        @final_documents += @ready_documents.count
        @final_census_records += census_records
        @final_stories += @ready_narratives.count
        @final_media += @ready_media.count
      end

      # Add total count
      counts << {
        buildings: @final_buildings,
        people: @final_people,
        documents: @final_documents,
        census_records: @final_census_records,
        stories: @final_stories,
        media: @final_media,
        year: 'Total'
      }

      ready_json = {
        results: {
          buildings: all_buildings,
          people: all_people,
          documents: all_documents,
          stories: all_stories,
          media: all_media
        },
        count: counts
      }

      response.headers.merge!(response_headers)
      render json: ready_json
    end

    private def search_query(class_name,chosen_query)
      class_object = class_name.constantize
      table_name = class_object.table_name
      class_object.column_names.each do |name|
        query = "#{table_name}.#{name}::varchar ILIKE :search OR "
        chosen_query.concat(query)
      end
      chosen_query
    end

    private def build_json(year)
      media_count = @ready_media.count
      census_records = 0
      census_record_names = %w[census record census census records]
      @ready_documents.each do |doc|
        census_records += 1 if census_record_names.include?(doc[:category].downcase)
      end
      rough_json = {
        year =>
        [
          { buildings: @ready_buildings },
          { people: @ready_people },
          { documents: @ready_documents },
          { stories: @ready_narratives },
          { media: @ready_media }
        ]
      }
      rough_count = {
        year =>
        {
          buildings: @ready_buildings.count,
          people: @ready_people.count,
          documents: @ready_documents.count,
          census_records:,
          stories: @ready_narratives.count,
          media: media_count
        }
      }
      @final_buildings += @ready_buildings.count
      @final_people += @ready_people.count
      @final_documents += @ready_documents.count
      @final_census_records += census_records
      @final_stories += @ready_narratives.count
      @final_media += media_count

      [rough_json, rough_count]
    end

    def make_building(record, year)
      return if record.nil?

      # Dynamically get census records and people for the year
      census_records = begin
        record.send("census#{year}_records")
      rescue StandardError
        []
      end
      people = begin
        record.send("people_#{year}")
      rescue StandardError
        []
      end

      # Skip if there are no census records for this year
      return if census_records.empty?

      # Collect people features for this year
      people_array = people

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
          properties: [people: document.people.uniq],
          data: Base64Encoder.encode_active_storage_file(document.file_attachment)
        }
      end

      # Collect building media
      media_array = record.photos.map     { |photo|     { type: 'photo',     id: photo.id } } +
                    record.audios.map     { |audio|     { type: 'audio',     id: audio.id } } +
                    record.videos.map     { |video|     { type: 'video',     id: video.id } } +
                    record.narratives.map { |narrative| { type: 'narrative', id: narrative.id } }

      {
        id: record.id,
        name: record.name.is_a?(Address) || record.name == Address.to_s ? record.primary_street_address : record.name,
        description: record.description,
        address: record.primary_street_address,
        location: record.coordinates,
        properties: [
          census_records:,
          people: people_array,
          media: media_array
        ],
        rich_description: record.rich_text_description,
        stories: building_narratives,
        photos: building_photos,
        videos: building_videos,
        audios: building_audios,
        documents: building_documents
      }
    end

    def sanitize_url(url)
      return nil if url.nil? || url.empty?
      # Remove double admin
      url.gsub('/admin/admin/', '/admin/')
    end

    def make_photo(record, year)
      return unless record.nil? == false

      census_people = :"census#{year}_records"
      url = ''
      data = ''
      if record.file_attachment.nil? == false
        url = rails_blob_url(record.file_attachment, only_path: true)
        data = Base64Encoder.encode_active_storage_file(record.file_attachment)
      end

      census_records = record.send(census_people)
      return if census_records.empty?

      {
        id: record.id,
        type: 'photo',
        description: record.description,
        caption: record.caption,
        attatchment: photo.file_attachment,
        URL: sanitize_url(url),
        properties: [buildings: record.buildings.ids, people: record.people.where.associated(census_people).ids],
        data:
      }
    end

    def make_narrative(record, year)
      return unless record.nil? == false

      census_people = :"census#{year}_records"
      census_records = record.send(census_people)
      return if census_records.empty?

      {
        id: record.id,
        story: record.story,
        sources: record.sources,
        properties: [buildings: record.buildings.ids, people: record.people.where.associated(census_people).ids]
      }
    end

    def make_audio(record, year)
      return unless record.nil? == false

      census_people = :"census#{year}_records"
      census_records = record.send(census_people)
      return if census_records.empty?

      {
        id: record.id,
        type: 'audio',
        description: record.description,
        caption: record.caption,
        URL: record.remote_url,
        properties: [buildings: record.buildings.ids, people: record.people.where.associated(census_people).ids],
        data: Base64Encoder.encode_url_file(record.remote_url)
      }
    end

    def make_video(record, year)
      return unless record.nil? == false

      census_people = :"census#{year}_records"
      census_records = record.send(census_people)
      return if census_records.empty?

      {
        id: record.id,
        type: 'video',
        description: record.description,
        caption: record.caption,
        URL: record.remote_url,
        properties: [buildings: record.buildings.ids, people: record.people.where.associated(census_people).ids],
        data: Base64Encoder.encode_url_file(record.remote_url)
      }
    end

    # should this have a record.nil? check like  the make methods for doc,narrative,photo,audio,video?
    def make_person(record, year)
      return if record.nil?

      # Dynamically get census records for the year
      census_records = record.send("census#{year}_records")
      return if census_records.empty?

      # Helper to collect media for the person
      media_array = record.photos.map     { |photo|     { type: 'photo',     id: photo.id } } +
                    record.audios.map     { |audio|     { type: 'audio',     id: audio.id } } +
                    record.videos.map     { |video|     { type: 'video',     id: video.id } } +
                    record.narratives.map { |narrative| { type: 'narrative', id: narrative.id } }

      # Collect narratives for the person
      person_narratives = record.narratives.map do |narrative|
        { record: narrative, sources: narrative.sources, story: narrative.story }
      end

      {
        id: record.id,
        name: record.name,
        description: record.description,
        properties: [
          census_records: census_records.map(&:id),
          buildings: record.buildings,
          media: media_array
        ],
        stories: person_narratives
      }
    end

    def make_document(record, year)
      return unless record.nil? == false

      url = ''
      url = rails_blob_url(record.file_attachment, only_path: true) if record.file_attachment.nil? == false
      data = Base64Encoder.encode_active_storage_file(record.file_attachment) if record.file_attachment.present?
      census_record_names = %w[census record census census records]
      if census_record_names.include?(record.document_category.name.downcase)
        census_people = :"census#{year}_records"
        census_records = record.send(census_people)
        return if census_records.empty?

        {
          id: record.id,
          category: record.document_category.name,
          name: record.name,
          description: record.description,
          URL: sanitize_url(url),
          properties: [people: record.people.where.associated(census_people).ids.uniq],
          data:
        }
      else
        {
          id: record.id,
          category: record.document_category.name,
          name: record.name,
          description: record.description,
          URL: sanitize_url(url),
          properties: [],
          data:
        }
      end
    end

    def search_photos(search)
      return Photograph.none if search.blank?

      Photograph.where('Photographs.searchable_text::varchar ILIKE :search', search: "%#{search}%")
                .includes(:buildings, :people, :file_attachment)
                .distinct
    end

    def search_narratives(search)
      narratives_query = search_query('Narrative', '')
      narratives_query = narratives_query.chomp('OR ')

      return Narrative.none if search.blank?

      Narrative.where(narratives_query, search: "%#{search}%")
               .includes(:sources, :story, :buildings, :people)
               .distinct
    end

    def search_audios(search)
      return Audio.none if search.blank?

      Audio.where('Audios.searchable_text::varchar ILIKE :search', search: "%#{search}%")
           .includes(:buildings, :people)
           .distinct
    end

    def search_videos(search)
      return Video.none if search.blank?

      Video.where('Videos.searchable_text::varchar ILIKE :search', search: "%#{search}%")
           .includes(:buildings, :people)
           .distinct
    end

    def search_people(search,year)
      relation = Person.includes(
        :photos, :audios, :videos, :narratives, :buildings,
        :"census#{year}_records"
      )
      return relation if search.blank?

      person_query = search_query('Person', '')
      person_query = person_query.chomp('OR ')
      relation.where(person_query, search: "%#{search}%").distinct
    end

    def search_documents(search)
      documents_query = search_query('Document', '')
      documents_query = documents_query.chomp('OR ')
      return Document.none if search.blank?

      Document.where(documents_query, search: "%#{search}%")
              .includes(:people, :document_category, :file_attachment)
              .distinct
    end
  end
end
