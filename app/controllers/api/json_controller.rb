module Api
  class JsonController < ApplicationController
    # "api/search?search=your_search"  provide your search as a query parameter called search like so
    #http://127.0.0.1:3000/api/search?search=#{params[:search]}&year=#{params[:year]} the year parameter should only be 1920,1910 or the word Both
    @@search_controller = SearchController.new
 
    def json
      @ready_json={"results": [],"count": []}
      @ready_count = []
      @final_buildings= 0
      @final_people= 0 
      @final_documents= 0 
      @final_census_records= 0
      @final_stories= 0 
      @final_media= 0
      list_years = ['1910','1920']

      list_years.each do |list_year|
      @buildings =  @@search_controller.search_buildings(params["search"],list_year)
      @ready_buildings =[]
      @buildings.each{|building|  @ready_buildings.append(make_building(building,list_year)) } 
      @ready_buildings = @ready_buildings.compact
      @people =  search_people(params["search"],list_year)
      @ready_people =[]

      @people.each{|person|  @ready_people.append(make_person(person,list_year)) } 
      @ready_people = @ready_people.compact

      @documents =  search_documents(params["search"])
      @ready_documents = []

      @documents.each{|document| @ready_documents.append(make_document(document,list_year))}
      @ready_documents = @ready_documents.compact

      @videos =  search_videos(params["search"])
      @audios =  search_audios(params["search"])
      @photos =  search_photos(params["search"])

      @ready_videos = []
      @ready_audios = []
      @ready_photos = []
      @ready_media  = []

      @videos.each{|video|  @ready_videos.append(make_video(video,list_year)) } 
      @audios.each{|audio|  @ready_audios.append(make_audio(audio,list_year)) } 
      @photos.each{|photo|  @ready_photos.append(make_photo(photo,list_year)) } 

      @ready_videos = @ready_videos.compact_blank
      @ready_audios = @ready_audios.compact_blank
      @ready_photos = @ready_photos.compact_blank

      @ready_media = @ready_videos + @ready_audios +  @ready_photos

      @ready_media = @ready_media.compact_blank

      @narratives =  search_narratives(params["search"])
      @ready_narratives =[]

      @narratives.each{|narrative|  @ready_narratives.append(make_narrative(narrative,list_year)) } 
      @ready_narratives = @ready_narratives.compact

      @finished_json = build_json(list_year)
      @ready_json[:results].append(@finished_json[0])
      @ready_count.append(@finished_json[1])

      end

      total_count ={"Total" => {
        
        
          "buildings": @final_buildings,
          "people": @final_people,
          "documents": @final_documents,
          "census_records": @final_census_records,
          "stories": @final_stories,
          "media": @final_media,
        

      }}
      @ready_count.append(total_count)
      @ready_json[:count].append(@ready_count)
      response.set_header('Access-Control-Allow-Origin', '*')
      render json: @ready_json
    end

    private def search_query(class_name,chosen_query)
      class_object = class_name.constantize
      table_name = class_object.table_name
      class_object.column_names.each do |name|
        query= "#{table_name}.#{name}::varchar ILIKE :search OR "
        chosen_query = chosen_query.concat(query)
      end
      chosen_query
    end

    private def build_json(year)
      media_count = @ready_media.count
      census_records = 0
      @ready_documents.each  do |doc|
        if doc[:category].downcase == "census record" || doc[:category].downcase == "census" || doc[:category].downcase == "census records"
          census_records += 1
        end
      end
    rough_json = { 
       
        
    year =>   [
          {"buildings": @ready_buildings},
          {"people": @ready_people},
          {"documents": @ready_documents},
          {"stories": @ready_narratives},
          {"media": @ready_media},
    ]
        
      
    }
    rough_count = {
    year=>
        {
          "buildings": @ready_buildings.count,
          "people": @ready_people.count,
          "documents": @ready_documents.count,
          "census_records": census_records,
          "stories": @ready_narratives.count,
          "media": media_count,
        }
      }
    
    @final_buildings+=@ready_buildings.count
    @final_people+=@ready_people.count
    @final_documents+=@ready_documents.count
    @final_census_records+=census_records
    @final_stories+= @ready_narratives.count
    @final_media+=media_count
    
    
    return [rough_json,rough_count]

    end
    def make_building(record,year) #should this have a record.nil? check like  the make methods for doc,narrative,photo,audio,video?
      def get_media(record)
        media_array = []

        record.photos.each {|photo| media_array.append({"type": "photo","id": photo.id})}
        record.audios.each {|audio| media_array.append({"type": "audio","id": audio.id})}
        record.videos.each {|video| media_array.append({"type": "video","id": video.id})}
        record.narratives.each {|narrative| media_array.append({"type": "narrative","id": narrative.id})}

        return media_array
      end

      def get_censusrecord(census_array)
        json_array = []
        census_array.each {|census| json_array.append(census.id)}
        return json_array
      end
      def get_person(person)
        person_narratives = []
        person.narratives.each {|narrative| person_narratives.append({record: narrative,sources:narrative.sources,story:narrative.story})}
        person_photos = []
        person.photos.each {|photo| person_photos.append({record: photo,attatchment:photo.file_attachment,url:rails_blob_url(photo.file_attachment, only_path: true)}) }

        person_feature = {
          "person": person,
          "audios": person.audios,
          "narratives": person_narratives,
          "videos": person.videos,
          "photos": person_photos
        }
      end
      person_array_1910 =[]
      person_array_1920 =[]
      record.people_1910.each {|person| person_array_1910.append(get_person(person))}
      record.people_1920.each {|person| person_array_1920.append(get_person(person))}
      building_narratives = []
      record.narratives.each {|narrative| building_narratives.append({record: narrative,sources:narrative.sources,story:narrative.story})}
      building_photos = []

      if record.photos.empty? == false
      record.photos.each {|photo| building_photos.append({record: photo,attatchment:photo.file_attachment,url:rails_blob_url(photo.file_attachment, only_path: true)}) }
      end
      captured_1910 = year == '1910' ? get_censusrecord(record.census1910_records) : []
      captured_1920 = year == '1920' ? get_censusrecord(record.census1920_records) : []

      captured_person_array1910 = year == '1910' ? person_array_1910 : []
      captured_person_array1920 = year == '1920' ? person_array_1920 : []
      
     
        feature = {
          "id": record.id,
          "name": record.name,
          "description": record.description,
          "address": record.primary_street_address,
          "location": record.coordinates,
          "properties": ["census_records1920": captured_1920, "census_records1910": captured_1910, "people1920": captured_person_array1920, "people1910": captured_person_array1910,"media": get_media(record)  ],
          "rich_description": record.rich_text_description,
          "stories": building_narratives
        }
      
      if record.census1920_records.empty? && year =='1920'
        return
      end
      if record.census1910_records.empty? && year =='1910'
        return
      end
      return feature
    end


    def search_photos(search)
      if search.present?
       photos = Photograph.where('Photographs.searchable_text::varchar ILIKE :search',:search => "%#{search}%").ids.uniq
       photos = photos.flatten.uniq
       photos = Photograph.where(id: photos)
       
      else
        photos = nil
      end
      photos

            
    end

    def make_photo(record,year)
      if record.nil? == false
        census_people = :"census#{year}_records"
        url = ""
        thumbnail = ""
        if record.file_attachment.nil? == false
             url =  rails_blob_url(record.file_attachment, only_path: true)  
            
             thumbnail = rails_blob_url(record.file_attachment, host: ENV['BASE_URL'])  
            
        end

        if year == "1920" && record.people.where.associated(:census1920_records).empty?
          return
        end
        if year == "1910" && record.people.where.associated(:census1910_records).empty?
          return
        end
        
          feature = {
            "id": record.id,
            "type": "photo",
            "description": record.description,
            "caption": record.caption,
            "URL": url,
            "properties": ["thumbnail": thumbnail,"buildings": record.buildings.ids, "people": record.people.where.associated(census_people).ids],
            
        }

          return feature
        
        
        
      else
        return
      end
            
    end



    def search_narratives(search)
      narratives_query  = ''
      rich_text_query = ''
      narratives_query  = search_query('Narrative',narratives_query)
      rich_text_query = search_query('ActionText::RichText',rich_text_query)
      rich_text_query = rich_text_query.chomp("OR ")
      narratives_query  = narratives_query.chomp("OR ")
      if search.present?
        narratives = Narrative.where(narratives_query,:search => "%#{search}%").ids.uniq
        narratives_stories = Narrative.joins(:rich_text_story).where(@rich_text_query,:search => "%#{search}%").ids.uniq
        narratives_sources = Narrative.joins(:rich_text_sources).where(@rich_text_query,:search => "%#{search}%").ids.uniq
        narratives << narratives_stories
        narratives << narratives_sources
        narratives = narratives.flatten.uniq
        narratives = Narrative.where(id: narratives)
      else
        narratives = nil
      end
      narratives
    end

    def make_narrative(record,year)
      if record.nil? == false
        
       
          census_people = :"census#{year}_records"
          
          if year == "1920" && record.people.where.associated(:census1920_records).empty?
            return
          end
          if year == "1910" && record.people.where.associated(:census1910_records).empty?
            return
          end
          feature = {
            "id": record.id,
            "story": record.story,
            "sources": record.sources,
            "properties": ["buildings": record.buildings.ids, "people": record.people.where.associated(census_people).ids],
          }
          return feature
       
      else
        return
      end
    end

    def search_videos(search)
      if search.present?
       videos = Video.where('Videos.searchable_text::varchar ILIKE :search',:search => "%#{search}%").ids.uniq
       videos = videos.flatten.uniq
       videos = Video.where(id: videos)
       
      else
        videos = nil
      end
      videos

            
    end
    def search_audios(search)
      if search.present?
       audios = Audio.where('Audios.searchable_text::varchar ILIKE :search',:search => "%#{search}%").ids.uniq
       audios = audios.flatten.uniq
       audios = Audio.where(id: audios)
      else
        audios = nil
      end
      audios
    end

    def make_audio(record,year)
      if record.nil? == false
        census_people = :"census#{year}_records"
        
        if year == "1920" && record.people.where.associated(:census1920_records).empty?
          return
        end
        if year == "1910" && record.people.where.associated(:census1910_records).empty?
          return
        end

          feature = {
            "id": record.id,
            "type": "audio",
            "description": record.description,
            "caption": record.caption,
            "URL": record.remote_url,
            "properties": ["buildings": record.buildings.ids, "people": record.people.where.associated(census_people).ids],
          }
          return feature
       

      else
        return
      end
    end

    def make_video(record,year)
      if record.nil? == false
        census_people = :"census#{year}_records"

        if year == "1920" && record.people.where.associated(:census1920_records).empty?
          return
        end
        if year == "1910" && record.people.where.associated(:census1910_records).empty?
          return
        end
        
          feature = {
            "id": record.id,
            "type": "video",
            "description": record.description,
            "caption": record.caption,
            "URL": record.remote_url,
            "properties": ["buildings": record.buildings.ids, "people": record.people.where.associated(census_people).ids],
            
        }

          return feature
        
        

        
      else
        return
      end
            
    end

    def make_person(record,year) #should this have a record.nil? check like  the make methods for doc,narrative,photo,audio,video?
      def get_media(record)
        media_array = []
        record.photos.each {|photo| media_array.append({"type": "photo","id": photo.id})}
        record.audios.each {|audio| media_array.append({"type": "audio","id": audio.id})}
        record.videos.each {|video| media_array.append({"type": "video","id": video.id})}
        record.narratives.each {|narrative| media_array.append({"type": "narrative","id": narrative.id})}
        return media_array
      end

      def get_censusrecord(census_array)
        json_array = []
        census_array.each {|census| json_array.append(census.id)}
        return json_array
      end
      person_narratives = []
      record.narratives.each {|narrative| person_narratives.append({record: narrative,sources:narrative.sources,story:narrative.story})}
      #is this person_photos below needed?
      person_photos = []
      if record.photos.empty? == false
        record.photos.each {|photo| person_photos.append({record: photo,attatchment:photo.file_attachment,url:rails_blob_url(photo.file_attachment, only_path: true)}) }
      end
      #is this person_photos above needed?
      
        captured_1910 = year == '1910' ? get_censusrecord(record.census1910_records) : []
        captured_1920 = year == '1920' ? get_censusrecord(record.census1920_records) : []
        feature = {
          "id": record.id,
          "name": record.name,
          "description": record.description,
          "properties": ["census_records1920": captured_1920,"census_records1910": captured_1910,"buildings": record.buildings,"media": get_media(record)  ],
          "stories": person_narratives
        }
      
      if record.census1920_records.empty? && year =='1920'
        return
      end
      if record.census1910_records.empty? && year =='1910'
        return
      end
      return feature
    end

    def search_documents(search)
      documents_query  = ''
      documents_query  = search_query('Document',documents_query)
      documents_query  = documents_query.chomp('OR ')
      if search.present?
        documents = Document.where(documents_query,:search => "%#{search}%").uniq
      else
        documents = nil
      end
      documents
    end

    def make_document(record,year)
      if record.nil? == false
        url = ""
        if record.file_attachment.nil? == false
             url =  rails_blob_url(record.file_attachment, only_path: true)
        end
        if record.document_category.name.downcase == "census record" || record.document_category.name.downcase == "census" || record.document_category.name.downcase == "census records"
          census_people = :"census#{year}_records"
          
          if year == "1920" && record.people.where.associated(:census1920_records).empty?
            return
          end
          if year == "1910" && record.people.where.associated(:census1910_records).empty?
            return
          end
            feature = {
              "id": record.id,
              "category": record.document_category.name,
              "name": record.name,
              "description": record.description,
              "URL": url,
              "properties": ["people": record.people.where.associated(census_people).ids.uniq ],
            }
            return feature
         
          
        else
          feature = {
            "id": record.id,
            "category": record.document_category.name,
            "name": record.name,
            "description": record.description,
            "URL": url,
            "properties": [],
          }
        return feature
        end
      else
        return
      end
    end




    def search_people(search,year)
      @census_query = ''
      @building_query = ''
      @person_query = ''
      @audio_query = ''
      @video_query = ''
      @photo_query = ''
      @narrative_query = ''
      @rich_text_query = ''
      @address_query = ''
      @documents_query  = ''

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

      @building_query = @building_query.chomp("OR ")
      @census_query = @census_query.chomp("OR ")
      @person_query = @person_query.chomp("OR ")
      @audio_query = @audio_query.chomp("OR ")
      @video_query = @video_query.chomp("OR ")
      @photo_query = @photo_query.chomp("OR ")
      @narrative_query = @narrative_query.chomp("OR ")
      @rich_text_query = @rich_text_query.chomp("OR ")
      @address_query  = @address_query.chomp("OR ")
      @documents_query  = @documents_query.chomp("OR ")

      if search.present?
          @people = Person.where(@person_query,:search => "%#{search}%").ids.uniq
          @people_photo = Person.joins(:photos).where("Photographs.searchable_text::varchar ILIKE :search",:search => "%#{search}%").ids.uniq
          @people_video = Person.joins(:videos).where("Videos.searchable_text::varchar ILIKE :search",:search => "%#{search}%").ids.uniq
          @people_audio = Person.joins(:audios).where("Audios.searchable_text::varchar ILIKE :search",:search => "%#{search}%").ids.uniq
          @people_narrative = Person.joins(:narratives).where(@narrative_query,:search => "%#{search}%").ids.uniq
          @people_action_text_story = Person.joins(narratives: :rich_text_story).where(@rich_text_query,:search => "%#{search}%").ids.uniq
          @people_action_text_sources = Person.joins(narratives: :rich_text_sources).where(@rich_text_query,:search => "%#{search}%").ids.uniq
          @people_document = Person.joins(:documents).where(@documents_query,:search => "%#{search}%").ids.uniq

          census_record_year = :"census#{year}_records"
          building_year = :"buildings_#{year}"



          @people_census = Person.joins(census_record_year).where(@census_query,:search => "%#{search}%").ids.uniq
          @people_buildings = Person.joins(building_year).where(@person_query,:search => "%#{search}%").ids.uniq
          
          @people << @people_photo
          @people << @people_video
          @people << @people_audio
          @people << @people_narrative
          @people <<  @people_action_text_sources
          @people <<  @people_action_text_story
          @people << @people_document

          
          @people << @people_census
          @people << @people_buildings
          @people = @people.flatten.uniq
          @people = Person.where(id: @people)
        
      else
        @buildings = Building.all
      end
    end
  end
end