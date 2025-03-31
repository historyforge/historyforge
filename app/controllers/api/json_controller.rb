module Api
  class JsonController < ApplicationController
   # "api/search?search=your_search"  provide your search as a query parameter called search like so
   #http://127.0.0.1:3000/api/search?search=#{params[:search]}&year=#{params[:year]} the year parameter should only be 1920,1910 or the word Both
   @@search_controller = SearchController.new
 
   def json
      
    
      
      @buildings =  @@search_controller.search_buildings(params["search"],params["year"])
      @ready_buildings =[]
      
      @buildings.each{|building|  @ready_buildings.append(make_building(building,params["year"])) } 
      @ready_buildings = @ready_buildings.compact
      @finished_json = build_json
      response.set_header('Access-Control-Allow-Origin', '*')
      render json: @finished_json

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
   

    private def build_json
      {
        "results":
        [
          {"buildings": @ready_buildings}
          
        
        ],

        
        "count":
        { 
          "buildings": @ready_buildings.count


        }
      }
      
    end

    def make_building(record,year)

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
      if year == '1920'
       
       
       
            feature = {
          
            "id": record.id,
            "name": record.name,
            "description": record.description,
            "address": record.primary_street_address,
            "location": record.coordinates,
            "properties": ["census_records1920": get_censusrecord(record.census1920_records),"census_records1910": [],"people1920": person_array_1920, "people1910": [],"media": get_media(record)  ],
            "rich_description": record.rich_text_description,
            "stories": building_narratives
            
          
        }
     
      elsif year == '1910'
        feature = {
          
        "id": record.id,
        "name": record.name,
        "description": record.description,
        "address": record.primary_street_address,
        "location": record.coordinates,
        "properties": ["census_records1920":[] ,"census_records1910": get_censusrecord(record.census1910_records),"people1920": [], "people1910": person_array_1910,"media": get_media(record)  ],
        "rich_description": record.rich_text_description,
        "stories": building_narratives
        
      
    }

      elsif year == 'Both'
        feature = {
          
        "id": record.id,
        "name": record.name,
        "description": record.description,
        "address": record.primary_street_address,
        "location": record.coordinates,
        "properties": ["census_records1920": get_censusrecord(record.census1920_records) ,"census_records1910": get_censusrecord(record.census1910_records),"people1920": person_array_1920, "people1910": person_array_1910,"media": get_media(record)  ],
        "rich_description": record.rich_text_description,
        "stories": building_narratives
        
      
    }
      end 
      
      
     
      if record.census1920_records.empty? && year =='1920'
        
        return 
     end

     if record.census1910_records.empty? && year =='1910'
      
      return 
   end
      
      return feature
    end
    
  end
end