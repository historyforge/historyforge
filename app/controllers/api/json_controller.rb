module Api
  class JsonController < ApplicationController
    # "api/json?search=your_search" provide your search as a query parameter called search like so
    # http://127.0.0.1:3000/api/json?search=#{params[:search]}
    @@search_controller = SearchController.new
    ALLOWED_ORIGINS = %w[http://localhost:5173 http://localhost:5174 https://greenwood.jacrys.com https://jacrys.com].freeze

    def json
      # rq = {
      #   origin: request.headers['Origin'],
      #   host: request.host
      # }
      # if ALLOWED_ORIGINS.include?(rq[:origin]) || (rq[:host] == 'localhost' && rq[:origin].nil?)
      #   response_headers = if rq[:origin].nil?
      #                        { 'Access-Control-Allow-Origin' => 'localhost' }
      #                      else
      #                        { 'Access-Control-Allow-Origin' => rq[:origin] }
      #                      end
      # else
        # Handle requests from disallowed origins (e.g., return a 403 Forbidden or omit the header)
        # response_headers = {} # or {"Access-Control-Allow-Origin": "null"} (use with caution)
        # render status: :forbidden, plain: 'Forbidden' and return
      # end
      response_headers = { 'Access-Control-Allow-Origin' => '*' }
      response_headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
      response_headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization, X-Requested-With'
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
        @buildings = @@search_controller.search_buildings(params['search'], list_year).includes(
          :narratives, :photos, :audios, :videos, :addresses,
          :"people_#{list_year}", :"census#{list_year}_records"
        ).distinct
        @ready_buildings = @buildings.filter_map { |b| make_building(b, list_year)&.merge(year: list_year) }
        all_buildings.concat(@ready_buildings)

        @people = search_people(params['search'], list_year)
        @ready_people = @people.filter_map { |p| make_person(p, list_year)&.merge(year: list_year) }
        all_people.concat(@ready_people)

        @documents = search_documents(params['search'], list_year)
        @ready_documents = @documents.filter_map { |d| make_document(d, list_year)&.merge(year: list_year) }
        all_documents.concat(@ready_documents)

        @videos = search_videos(params['search'], list_year)
        @audios = search_audios(params['search'], list_year)
        @photos = search_photos(params['search'], list_year)

        @ready_videos = @videos&.map { |v| make_video(v, list_year)&.merge(year: list_year) }&.compact_blank || []
        @ready_audios = @audios&.map { |a| make_audio(a, list_year)&.merge(year: list_year) }&.compact_blank || []
        @ready_photos = @photos&.map { |p| make_photo(p, list_year)&.merge(year: list_year) }&.compact_blank || []
        @ready_media = @ready_videos + @ready_audios + @ready_photos
        all_media.concat(@ready_media)

        @narratives = search_narratives(params['search'], list_year)
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
          census_records:,
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
      media_count = @ready_media.where(:year).count
      census_records = 0
      census_record_names = %w[census record census census records]
      @ready_documents.each do |doc|
        census_records += 1 if census_record_names.include?(doc[:category].downcase)
      end
      rough_json = {
        buildings: @ready_buildings.where(year:),
        people: @ready_people.where(year:),
        documents: @ready_documents.where(year:),
        stories: @ready_narratives.where(year:),
        media: @ready_media.where(year:)
      }
      rough_count = {
        buildings: @ready_buildings.where(year:).count,
        people: @ready_people.where(year:).count,
        documents: @ready_documents.where(year:).count,
        census_records: census_records.where(year:),
        stories: @ready_narratives.count.where(year:),
        media: media_count,
        year:
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

      census_association = :"census#{year}_records"
      people_association = :"people_#{year}"
      # Dynamically get census records and people for the year
      census_records = begin
        record.send(census_association)
      rescue StandardError
        []
      end
      people = begin
        record.send(people_association)
      rescue StandardError
        []
      end

      # Skip if there are no census records for this year
      return if census_records.empty?

      # Collect people features for this year
      people_array = people.map do |person|
        {
          id: person.id,
          name: person.searchable_name,
          description: person.description,
          race: person.race,
          gender: person.sex,
          age: person.age_in_year(year.to_i) || person["census#{year}_record"].age,
          place_of_birth: person.pob,
          birth_year: person.birth_year,
          notes: person.notes,
          year:,
          properties: {
            census_records: person.census_records.flat_map(&:itself),
            documents: person.documents.map do |b|
              {
                id: b.id,
                category: b.document_category.name,
                name: b.name,
                description: b.description,
                URL: b.file_attachment.present? ? sanitize_url(rails_blob_url(b.file_attachment, only_path: true)) : nil,
                data_uri: b.data_uri
              }
            end,
            stories: person.narratives.map do |b|
              {
                id: b.id,
                type: 'story',
                record: b,
                sources: b.sources,
                story: b.story
              }
            end,
            audios: person.audios.map  do |b|
              {
                id: b.id,
                type: 'audio',
                description: b.description,
                caption: b.caption,
                URL: b.remote_url,
                data_uri: b.data_uri
              }
            end,
            videos: person.videos.map do |b|
              {
                id: b.id,
                type: 'audio',
                description: b.description,
                caption: b.caption,
                URL: b.remote_url,
                data_uri: b.data_uri
              }
            end,
            photos: person.photos.map do |b|
              {
                id: b.id,
                type: 'photo',
                description: b.description,
                caption: b.caption,
                attatchment: b.file_attachment,
                URL: b.file_attachment.present? ? sanitize_url(rails_blob_url(b.file_attachment, only_path: true)) : nil,
                data_uri: b.data_uri
              }
            end
          }
        }
      end

      # Collect building narratives
      building_narratives = record.narratives.map do |narrative|
        { record: narrative, sources: narrative.sources, story: narrative.story, year: }
      end

      # Collect building photos
      building_photos = record.photos.map do |photo|
        census_records = photo.send(census_association) if photo.respond_to?(census_association)
        {
          id: photo.id,
          type: 'photo',
          description: photo.description,
          caption: photo.caption,
          attatchment: photo.file_attachment,
          URL: photo.file_attachment.present? ? sanitize_url(rails_blob_url(photo.file_attachment, only_path: true)) : nil,
          properties: [buildings: photo.buildings, people: photo.people, census_records:],
          data_uri: photo.data_uri,
          year:
        }
      end

      # Collect building audios
      building_audios = record.audios.map do |audio|
        census_records = audio.send(census_association) if audio.respond_to?(census_association)
        {
          id: audio.id,
          type: 'audio',
          description: audio.description,
          caption: audio.caption,
          URL: audio.remote_url,
          properties: {
            buildings: audio.buildings,
            people: audio.people,
            census_records:
          },
          data_uri: audio.data_uri,
          year:
        }
      end

      # Collect building videos
      building_videos = record.videos.map do |video|
        census_records = video.send(census_association) if video.respond_to?(census_association)
        {
          id: video.id,
          type: 'video',
          description: video.description,
          caption: video.caption,
          URL: video.remote_url,
          properties: {
            buildings: video.buildings,
            people: video.people,
            census_records:
          },
          data_uri: video.data_uri,
          year:
        }
      end

      # Collect building documents
      building_documents = record.documents.map do |document|
        {
          id: document.id,
          category: document.document_category.name,
          name: document.name,
          description: document.description,
          URL: document.file_attachment.present? ? sanitize_url(rails_blob_url(document.file_attachment, only_path: true)) : nil,
          properties: {
            people: document.people.uniq,
            census_records: document.people.flat_map(&:census_records).uniq
          },
          data_uri: document.data_uri
        }
      end

      {
        id: record.id,
        name: record.name,
        type: record.building_types,
        description: record.description,
        address: record.primary_street_address,
        location: record.coordinates,
        properties: {
          census_records:,
          people: people_array,
          stories: building_narratives,
          photos: building_photos,
          audios: building_audios,
          videos: building_videos,
          documents: building_documents
        },
        rich_description: record.rich_text_description,
        year:
      }
    end

    def make_photo(record, year)
      return unless record.nil? == false

      census_people = :"census#{year}_records"
      census_records = record.people.flat_map { |p| p.send(census_people) }
      url = ''
      if record.file_attachment.nil? == false
        url = record.file_attachment.present? ? sanitize_url(rails_blob_url(record.file_attachment, only_path: true, host: ENV.fetch('BASE_URL', nil))) : nil
      end

      return if census_records.empty?

      {
        id: record.id,
        type: 'photo',
        description: record.description,
        caption: record.caption,
        URL: url,
        data_uri: record.data_uri,
        properties: {
          people: record.people.distinct.map { |p| { id: p.id, name: p.searchable_name, sex: p.sex, race: p.race } },
          census_records: census_records.map { |cr| { id: cr.id, name: "#{cr.first_name} #{cr.middle_name} #{cr.last_name}", age: cr.age, gender: cr.sex, race: cr.race } },
          buildings: record.buildings.distinct.map { |b| { id: b.id, name: b.address.address, street_address: b.address.address, building_types: b.building_types } }
        }
      }
    end

    def make_narrative(record, year)
      return unless record.nil? == false

      census_people = :"census#{year}_records"
      census_records = record.people.flat_map { |p| p.send(census_people) }
      return if census_records.empty?

      {
        id: record.id,
        story: record.story,
        sources: record.sources,
        properties: {
          people: record.people.distinct.map { |p| { id: p.id, name: p.searchable_name, sex: p.sex, race: p.race } },
          census_records: census_records.map { |cr| { id: cr.id, name: "#{cr.first_name} #{cr.middle_name} #{cr.last_name}", age: cr.age, gender: cr.sex, race: cr.race } },
          buildings: record.buildings.distinct.map { |b| { id: b.id, name: b.address.address, street_address: b.address.address, building_types: b.building_types } }
        }
      }
    end

    def make_audio(record, year)
      return unless record.nil? == false

      census_people = :"census#{year}_records"
      census_records = record.people.flat_map { |p| p.send(census_people) }
      return if census_records.empty?

      {
        id: record.id,
        type: 'audio',
        description: record.description,
        caption: record.caption,
        URL: record.remote_url,
        data_uri: record.data_uri,
        properties: {
          people: record.people.distinct.map { |p| { id: p.id, name: p.searchable_name, sex: p.sex, race: p.race } },
          census_records: census_records.map { |cr| { id: cr.id, name: "#{cr.first_name} #{cr.middle_name} #{cr.last_name}", age: cr.age, gender: cr.sex, race: cr.race } },
          buildings: record.buildings.distinct.map { |b| { id: b.id, name: b.address.address, street_address: b.address.address, building_types: b.building_types } }
        }
      }
    end

    def make_video(record, year)
      return unless record.nil? == false

      census_people = :"census#{year}_records"
      census_records = record.people.flat_map { |p| p.send(census_people) }
      return if census_records.empty?

      {
        id: record.id,
        type: 'video',
        description: record.description,
        caption: record.caption,
        URL: record.remote_url,
        properties: {
          people: record.people.distinct.map { |p| { id: p.id, name: p.searchable_name, sex: p.sex, race: p.race } },
          census_records: census_records.map { |cr| { id: cr.id, name: "#{cr.first_name} #{cr.middle_name} #{cr.last_name}", age: cr.age, gender: cr.sex, race: cr.race } },
          buildings: record.buildings.distinct.map { |b| { id: b.id, name: b.address.address, street_address: b.address.address, building_types: b.building_types } }
        }
      }
    end

    # should this have a record.nil? check like  the make methods for doc,narrative,photo,audio,video?
    def make_person(record, year)
      return if record.nil?

      # Dynamically get census records for the year
      census_records = record.send("census#{year}_records")
      return if census_records.empty?

      # Collect narratives for the person
      person_narratives = record.narratives.map do |narrative|
        { id: narrative.id, record: narrative, sources: narrative.sources, story: narrative.story }
      end

      {
        id: record.id,
        name: record.searchable_name,
        description: record.description,
        race: record.race,
        gender: record.sex,
        age: record.age_in_year(year.to_i) || record["census#{year}_record"].age,
        place_of_birth: record.pob,
        birth_year: record.birth_year,
        notes: record.notes,
        year:,
        properties: {
          census_records: record.census_records.flat_map(&:itself),
          documents: record.documents.map do |b|
            {
              id: b.id,
              category: b.document_category.name,
              name: b.name,
              description: b.description,
              filename: b.file_attachment.present? ? b.file_attachment.filename.to_s : nil,
              content_type: b.file_attachment.present? ? b.file_attachment.content_type : nil,
              URL: b.file_attachment.present? ? sanitize_url(rails_blob_url(b.file_attachment, only_path: true)) : nil,
              data_uri: b.data_uri
            }
          end,
          stories: person_narratives.map do |b|
            {
              id: b[:id],
              type: 'story',
              record: b[:record],
              sources: b[:sources],
              story: b[:story]
            }
          end,
          audios: record.audios.map do |b|
            {
              id: b.id,
              type: 'audio',
              description: b.description,
              caption: b.caption,
              URL: b.remote_url,
              data_uri: b.data_uri
            }
          end,
          videos: record.videos.map do |b|
            {
              id: b.id,
              type: 'audio',
              description: b.description,
              caption: b.caption,
              URL: b.remote_url,
              data_uri: b.data_uri
            }
          end,
          photos: record.photos.map do |b|
            {
              id: b.id,
              type: 'photo',
              description: b.description,
              caption: b.caption,
              attatchment: b.file_attachment,
              filename: b.file_attachment.present? ? b.file_attachment.filename.to_s : nil,
              content_type: b.file_attachment.present? ? b.file_attachment.content_type : nil,
              URL: b.file_attachment.present? ? sanitize_url(rails_blob_url(b.file_attachment, only_path: true)) : nil,
              data_uri: b.data_uri
            }
          end
        }
      }
    end

    def make_document(record, year)
      return unless record.nil? == false

      url = ''
      url = rails_blob_url(record.file_attachment, only_path: true) if record.file_attachment.nil? == false
      census_record_names = ['census record', 'census', 'census records', 'census_records', 'census_record']
      if census_record_names.include?(record.document_category.name.downcase)
        census_people = :"census#{year}_records"
        census_records = record.people.flat_map { |p| p.send(census_people) }
        return if census_records.empty?

        {
          id: record.id,
          category: record.document_category.name,
          name: record.name,
          description: record.description,
          filename: record.file_attachment.filename.to_s,
          content_type: record.file_attachment.content_type,
          URL: url,
          data_uri: record.data_uri,
          properties: {
            people: record.people.distinct.map { |p| { id: p.id, name: p.searchable_name, sex: p.sex, race: p.race } },
            census_records: census_records.map { |cr| { id: cr.id, name: "#{cr.first_name} #{cr.middle_name} #{cr.last_name}", age: cr.age, gender: cr.sex, race: cr.race } },
            buildings: record.buildings.distinct.map { |b| { id: b.id, name: b.address.address, street_address: b.address.address, building_types: b.building_types } }
          },
          year:
        }
      else
        {
          id: record.id,
          category: record.document_category&.name,
          name: record.name,
          description: record.description,
          filename: record.file_attachment.filename.to_s,
          content_type: record.file_attachment.content_type,
          URL: url,
          data_uri: record.data_uri,
          properties: {},
          year:
        }
      end
    end

    def search_photos(search, year)
      if search.present?
        photos = Photograph.where('Photographs.searchable_text::varchar ILIKE :search', search: "%#{search}%").distinct.select(:id)
        photos = photos.to_a.flatten.uniq
        photos = Photograph.where(id: photos).includes(:buildings, people: [:"census#{year}_records"]).unscope(:order)
      else
        photos = nil
      end
      photos
    end

    def search_narratives(search, year)
      narratives_query = ''
      rich_text_query = ''
      narratives_query = search_query('Narrative',narratives_query)
      rich_text_query = search_query('ActionText::RichText', rich_text_query)
      rich_text_query = rich_text_query.chomp('OR ')
      narratives_query  = narratives_query.chomp('OR ')
      if search.present?
        narratives = Narrative.where(narratives_query, search: "%#{search}%").distinct.unscope(:order).ids
        narratives_stories = Narrative.joins(:rich_text_story).where(rich_text_query, search: "%#{search}%").distinct.unscope(:order).ids
        narratives_sources = Narrative.joins(:rich_text_sources).where(rich_text_query, search: "%#{search}%").distinct.unscope(:order).ids
        narratives << narratives_stories
        narratives << narratives_sources
        narratives = narratives.flatten.uniq
        narratives = Narrative.where(id: narratives).includes(:rich_text_story, :rich_text_sources, people: [:"census#{year}_records"]).unscope(:order)
      else
        narratives = nil
      end
      narratives
    end

    def search_audios(search, year)
      if search.present?
        audios = Audio.where('Audios.searchable_text::varchar ILIKE :search', search: "%#{search}%").distinct.select(:id)
        audios = audios.to_a.flatten.uniq
        audios = Audio.where(id: audios).includes(:buildings, people: [:"census#{year}_records"]).unscope(:order)
      else
        audios = nil
      end
      audios
    end

    def search_videos(search, year)
      if search.present?
        videos = Video.where('Videos.searchable_text::varchar ILIKE :search', search: "%#{search}%").distinct.select(:id)
        videos = videos.to_a.flatten.uniq
        videos = Video.where(id: videos).includes(:buildings, people: [:"census#{year}_records"]).unscope(:order)
      else
        videos = nil
      end
      videos
    end

    def search_people(search, year)
      @census_query = ''
      @building_query = ''
      @person_query = ''
      @audio_query = ''
      @video_query = ''
      @photo_query = ''
      @narrative_query = ''
      @rich_text_query = ''
      @address_query = ''
      @documents_query = ''

      @census_query = search_query("Census#{year}Record",@census_query)
      @building_query = search_query('Building',@building_query)
      @person_query = search_query('Person',@person_query)
      @audio_query = search_query('Audio',@audio_query)
      @video_query = search_query('Video',@video_query)
      @photo_query = search_query('Photograph',@photo_query)
      @narrative_query = search_query('Narrative',@narrative_query)
      @rich_text_query = search_query('ActionText::RichText',@rich_text_query)
      @address_query = search_query('Address',@address_query)
      @documents_query  = search_query('Document',@documents_query)

      @building_query = @building_query.chomp('OR ')
      @census_query = @census_query.chomp('OR ')
      @person_query = @person_query.chomp('OR ')
      @audio_query = @audio_query.chomp('OR ')
      @video_query = @video_query.chomp('OR ')
      @photo_query = @photo_query.chomp('OR ')
      @narrative_query = @narrative_query.chomp('OR ')
      @rich_text_query = @rich_text_query.chomp('OR ')
      @address_query  = @address_query.chomp('OR ')
      @documents_query  = @documents_query.chomp('OR ')

      if search.present?
        @people = Person.where(@person_query,search: "%#{search}%").includes(
          :"census#{year}_records",
          :"buildings_#{year}", :photos, :videos, :audios, :narratives, :documents
        ).distinct
        @people_photo = Person.joins(:photos).where('Photographs.searchable_text::varchar ILIKE :search', search: "%#{search}%").distinct
        @people_video = Person.joins(:videos).where('Videos.searchable_text::varchar ILIKE :search', search: "%#{search}%").distinct
        @people_audio = Person.joins(:audios).where('Audios.searchable_text::varchar ILIKE :search', search: "%#{search}%").distinct
        @people_narrative = Person.joins(:narratives).where(@narrative_query, search: "%#{search}%").distinct
        @people_action_text_story = Person.joins(narratives: :rich_text_story).where(@rich_text_query, search: "%#{search}%").distinct
        @people_action_text_sources = Person.joins(narratives: :rich_text_sources).where(@rich_text_query, search: "%#{search}%").distinct
        @people_document = Person.joins(:documents).where(@documents_query,search: "%#{search}%").distinct

        census_record_year = :"census#{year}_records"
        building_year = :"buildings_#{year}"

        @people_census = Person.joins(census_record_year).where(@census_query,search: "%#{search}%").distinct
        @people_buildings = Person.joins(building_year).where(@person_query,search: "%#{search}%").distinct

        @people = @people.to_a
        @people += @people_photo
        @people += @people_video
        @people += @people_audio
        @people += @people_narrative
        @people += @people_action_text_sources
        @people += @people_action_text_story
        @people += @people_document

        @people += @people_census
        @people += @people_buildings
        @people = @people.flatten.uniq
        @people = Person.where(id: @people)
      else
        @buildings = Building.all
      end
    end

    def search_documents(search, year)
      documents_query  = ''
      documents_query  = search_query('Document', documents_query)
      documents_query  = documents_query.chomp('OR ')
      return if search.blank?

      Document.where(documents_query, search: "%#{search}%").includes(
        :document_category, :file_attachment, :buildings, :people, people: :"census#{year}_records"
      ).distinct
    end

    def sanitize_url(url)
      return nil if url.blank?

      # Remove double admin
      url.gsub('/admin/admin/', '/admin/')
    end
  end
end
