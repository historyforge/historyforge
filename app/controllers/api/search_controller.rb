module Api
  class SearchController < ApplicationController
   # "api/search?search=your_search"  provide your search as a query parameter called search like so
   #http://127.0.0.1:3000/api/search?search=#{params[:search]}&year=#{params[:year]} the year parameter should only be 1920,1910 or the word Both
    def search
      @census_query = ''
      @building_query = ''
      @census1910_query=''
      @person_query1910 = ''
      @person_query1920 = ''
      @audio_query = ''
      @video_query = ''
      @photo_query = ''
      @narrative_query = ''

      @census_query = search_query('Census1920Record',@census_query)
      @census1910_query = search_query('Census1910Record',@census1910_query)
      @building_query = search_query('Building',@building_query)
      @person_query1910 = search_query('Person',@person_query1910)
      @person_query1920 = search_query('Person',@person_query1920)
      @audio_query = search_query('Audio',@audio_query)
      @video_query = search_query('Video',@video_query)
      @photo_query = search_query('Photograph',@photo_query)
      @narrative_query = search_query('Narrative',@narrative_query)

     
      @building_query = @building_query.chomp("OR ")
      @census_query = @census_query.chomp("OR ")
      @census1910_query = @census1910_query.chomp("OR ")
      @person_query1910 = @person_query1910.chomp("OR ")
      @person_query1920 = @person_query1920.chomp("OR ")
      @audio_query = @audio_query.chomp("OR ")
      @video_query = @video_query.chomp("OR ")
      @photo_query = @photo_query.chomp("OR ")
      @narrative_query = @narrative_query.chomp("OR ")


      if params["search"].present?
        if params["year"] == 'Both'
          #binding.pry
         @buildings = Building.where(@building_query,:search => "%#{params["search"]}%").ids.uniq
         @building_photo = Building.joins(:photos).where(@photo_query,:search => "%#{params["search"]}%").ids.uniq
         @building_video = Building.joins(:videos).where(@video_query,:search => "%#{params["search"]}%").ids.uniq
         @building_audio = Building.joins(:audios).where(@audio_query,:search => "%#{params["search"]}%").ids.uniq
         @building_narrative = Building.joins(:narratives).where(@narrative_query,:search => "%#{params["search"]}%").ids.uniq

         @buildings2 = Building.joins(:census1920_records).where(@census_query,:search => "%#{params["search"]}%").ids.uniq
         @buildings3 = Building.joins(:census1910_records).where(@census1910_query,:search => "%#{params["search"]}%").ids.uniq
         @buildings_people1920 = Building.joins(:people_1920).where(@person_query1920,:search => "%#{params["search"]}%").ids.uniq
         @people_photo1920 = Building.joins(people_1920: :photos).where(@photo_query,:search => "%#{params["search"]}%").ids.uniq
         @people_video1920 = Building.joins(people_1920: :videos).where(@video_query,:search => "%#{params["search"]}%").ids.uniq
         @people_audio1920 = Building.joins(people_1920: :audios).where(@audio_query,:search => "%#{params["search"]}%").ids.uniq
         @people_narrative1920 = Building.joins(people_1920: :narratives).where(@narrative_query,:search => "%#{params["search"]}%").ids.uniq
         @buildings_people1910 = Building.joins(:people_1910).where(@person_query1910,:search => "%#{params["search"]}%").ids.uniq
         @people_photo1910 = Building.joins(people_1910: :photos).where(@photo_query,:search => "%#{params["search"]}%").ids.uniq
         @people_video1910 = Building.joins(people_1910: :videos).where(@video_query,:search => "%#{params["search"]}%").ids.uniq
         @people_audio1910 = Building.joins(people_1910: :audios).where(@audio_query,:search => "%#{params["search"]}%").ids.uniq
         @people_narrative1910 = Building.joins(people_1910: :narratives).where(@narrative_query,:search => "%#{params["search"]}%").ids.uniq




          #binding.pry
          @buildings << @building_photo
         @buildings << @building_video
         @buildings << @building_audio
         @buildings << @building_narrative

         @buildings << @buildings2
         @buildings << @buildings3
         @buildings << @buildings_people1920
         @buildings << @people_photo1920
         @buildings << @people_video1920
         @buildings << @people_audio1920
         @buildings << @people_narrative1920

         @buildings << @buildings_people1910
         @buildings << @people_photo1910
         @buildings << @people_video1910
         @buildings << @people_audio1910
         @buildings << @people_narrative1910
         @buildings = @buildings.flatten.uniq
         @buildings = Building.where(id: @buildings)
          
        elsif params["year"] == '1910'
          @buildings = Building.where(@building_query,:search => "%#{params["search"]}%").ids.uniq
          @building_photo = Building.joins(:photos).where(@photo_query,:search => "%#{params["search"]}%").ids.uniq
          @building_video = Building.joins(:videos).where(@video_query,:search => "%#{params["search"]}%").ids.uniq
          @building_audio = Building.joins(:audios).where(@audio_query,:search => "%#{params["search"]}%").ids.uniq
          @building_narrative = Building.joins(:narratives).where(@narrative_query,:search => "%#{params["search"]}%").ids.uniq

          @buildings3 = Building.joins(:census1910_records).where(@census1910_query,:search => "%#{params["search"]}%").ids.uniq
          @buildings_people1910 = Building.joins(:people_1910).where(@person_query1910,:search => "%#{params["search"]}%").ids.uniq
          @people_photo1910 = Building.joins(people_1910: :photos).where(@photo_query,:search => "%#{params["search"]}%").ids.uniq
          @people_video1910 = Building.joins(people_1910: :videos).where(@video_query,:search => "%#{params["search"]}%").ids.uniq
          @people_audio1910 = Building.joins(people_1910: :audios).where(@audio_query,:search => "%#{params["search"]}%").ids.uniq
          @people_narrative1910 = Building.joins(people_1910: :narratives).where(@narrative_query,:search => "%#{params["search"]}%").ids.uniq
 
          @buildings << @building_photo
          @buildings << @building_video
          @buildings << @building_audio
          @buildings << @building_narrative
          
          @buildings << @buildings3
          @buildings << @buildings_people1910
          @buildings << @people_photo1910
          @buildings << @people_video1910
          @buildings << @people_audio1910
          @buildings << @people_narrative1910

          @buildings = @buildings.flatten.uniq
          @buildings = Building.where(id: @buildings)
        elsif params["year"] == '1920'
          @buildings = Building.where(@building_query,:search => "%#{params["search"]}%").ids.uniq
          @building_photo = Building.joins(:photos).where(@photo_query,:search => "%#{params["search"]}%").ids.uniq
          @building_video = Building.joins(:videos).where(@video_query,:search => "%#{params["search"]}%").ids.uniq
          @building_audio = Building.joins(:audios).where(@audio_query,:search => "%#{params["search"]}%").ids.uniq
          @building_narrative = Building.joins(:narratives).where(@narrative_query,:search => "%#{params["search"]}%").ids.uniq

          @buildings2 = Building.joins(:census1920_records).where(@census_query,:search => "%#{params["search"]}%").ids.uniq 
          @buildings_people1920 = Building.joins(:people_1920).where(@person_query1920,:search => "%#{params["search"]}%").ids.uniq
         @people_photo1920 = Building.joins(people_1920: :photos).where(@photo_query,:search => "%#{params["search"]}%").ids.uniq
         @people_video1920 = Building.joins(people_1920: :videos).where(@video_query,:search => "%#{params["search"]}%").ids.uniq
         @people_audio1920 = Building.joins(people_1920: :audios).where(@audio_query,:search => "%#{params["search"]}%").ids.uniq
         @people_narrative1920 = Building.joins(people_1920: :narratives).where(@narrative_query,:search => "%#{params["search"]}%").ids.uniq


         @buildings << @building_photo
         @buildings << @building_video
         @buildings << @building_audio
         @buildings << @building_narrative

          @buildings << @buildings2
          @buildings << @buildings_people1920
          @buildings << @people_photo1920
          @buildings << @people_video1920
          @buildings << @people_audio1920
          @buildings << @people_narrative1920
          @buildings = @buildings.flatten.uniq
          @buildings = Building.where(id: @buildings)
        end
      else
        @buildings = Building.all
      end
      
      @ready_buildings =[]
      
      @buildings.each{|building|  @ready_buildings.append(make_feature(building,params["year"])) } 
      
      @geojson = build_geojson
      response.set_header('Access-Control-Allow-Origin', '*')
      render json: @geojson
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
   

    private def build_geojson
      
      {
        type: "FeatureCollection",
        features: @ready_buildings
      }
      
    end

    private def make_feature(record,year)

      def get_person(person)
        person_feature = {
        "person": person,
        "audios": person.audios,
        "narratives": person.narratives,
        "videos": person.videos,
        "photos": person.photos


        }
      end
      person_array_1910 =[]
      person_array_1920 =[]
      record.people_1910.each {|person| person_array_1910.append(get_person(person))}
      record.people_1920.each {|person| person_array_1920.append(get_person(person))}
      if year == '1920'
            feature = {
          "type": "Feature",
          "geometry": {
            "type": "Point",
            "coordinates": record.coordinates
          },
          "properties": {
            "location_id": record.id,
            "title": record.name,
            "building_audios": record.audios,
            "building_narratives": record.narratives,
            "building_videos": record.videos,
            "building_photos": record.photos,
            "description": record.full_street_address,
            "1910": [],
            "1920": record.census1920_records,
            "1910_people": [],
            "1920_people": person_array_1920
          }
        }
     
      elsif year == '1910'
        feature = {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": record.coordinates
      },
      "properties": {
        "location_id": record.id,
        "title": record.name,
        "building_audios": record.audios,
        "building_narratives": record.narratives,
        "building_videos": record.videos,
        "building_photos": record.photos,
        "description": record.full_street_address,
        "1910": record.census1910_records,
        "1920": [],
        "1910_people": person_array_1910,
        "1920_people": []
        
      }
    } 

      elsif year == 'Both'
        feature = {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": record.coordinates
      },
      "properties": {
        "location_id": record.id,
        "title": record.name,
        "building_audios": record.audios,
        "building_narratives": record.narratives,
        "building_videos": record.videos,
        "building_photos": record.photos,
        "description": record.full_street_address,
        "1910": record.census1910_records,
        "1920": record.census1920_records,
        "1910_people": person_array_1910,
        "1920_people": person_array_1920
        
      }
    }
      end 
      
      
     
      if feature[:properties][:"1920"].empty? && year =='1920'
        
        return 
     end

     if feature[:properties][:"1910"].empty? && year =='1910'
      
      return 
   end
      
      return feature
    end

    

  end
end