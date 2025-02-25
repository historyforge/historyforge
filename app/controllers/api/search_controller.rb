module Api
  class SearchController < ApplicationController
   # "api/search?search=your_search"  provide your search as a query parameter called search like so
   #http://127.0.0.1:3000/api/search?search=#{params[:search]}&year=#{params[:year]}
    def search
      @census_query = ''
      @building_query = ''
      @census1910_query=''

      @census_query = search_query('Census1920Record',@census_query)
      @census1910_query = search_query('Census1910Record',@census1910_query)
      @building_query = search_query('Building',@building_query)
     
      @building_query = @building_query.chomp("OR ")
      @census_query = @census_query.chomp("OR ")
      @census1910_query = @census1910_query.chomp("OR ")

      if params["search"].present?
        if params["year"] == 'Both'
         @buildings = Building.where(@building_query,:search => "%#{params["search"]}%").ids.uniq
         @buildings2 = Building.joins(:census1920_records).where(@census_query,:search => "%#{params["search"]}%").ids.uniq
         @buildings3 = Building.joins(:census1910_records).where(@census1910_query,:search => "%#{params["search"]}%").ids.uniq


         @buildings << @buildings2
         @buildings << @buildings3
         @buildings = @buildings.flatten.uniq
         @buildings = Building.where(id: @buildings)
          
        elsif params["year"] == '1910'
          @buildings = Building.where(@building_query,:search => "%#{params["search"]}%").ids.uniq
          @buildings3 = Building.joins(:census1910_records).where(@census1910_query,:search => "%#{params["search"]}%").ids.uniq
 
 
          @buildings << @buildings3
          @buildings = @buildings.flatten.uniq
          @buildings = Building.where(id: @buildings)
        elsif params["year"] == '1920'
          @buildings = Building.where(@building_query,:search => "%#{params["search"]}%").ids.uniq
          @buildings2 = Building.joins(:census1920_records).where(@census_query,:search => "%#{params["search"]}%").ids.uniq 
 
          @buildings << @buildings2
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
            "description": record.full_street_address,
            "1910": [],
            "1920": record.census1920_records
            
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
        "description": record.full_street_address,
        "1910": record.census1910_records,
        "1920": []
        
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
        "description": record.full_street_address,
        "1910": record.census1910_records,
        "1920": record.census1920_records
        
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