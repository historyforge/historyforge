module Api
  class SearchController < ApplicationController
   
    def search
      @census_query = ''
      @building_query = ''
      @census_query = search_query('Census1920Record',@census_query)
      @building_query = search_query('Building',@building_query)
     
      @building_query = @building_query.chomp("OR ")
      @census_query = @census_query.chomp("OR ")
      if params["place"].present?
         @buildings = Building.where(@building_query,:search => "%#{params["place"]}%").ids.uniq
         @buildings2 = Building.joins(:census1920_records).where(@census_query,:search => "%#{params["place"]}%").ids.uniq
        
         @buildings << @buildings2
         @buildings = @buildings.flatten.uniq
         @buildings = Building.where(id: @buildings)
      else
        @buildings = Building.all
      end
      
      @ready_buildings =[]
      
      @buildings.each{|building|  @ready_buildings.append(make_feature(building)) } 
      
      @geojson = build_geojson
    
      render json: @geojson
    end


    private def search_query(class_name,chosen_query)
      class_object = class_name.constantize
      table_name = class_object.table_name
      class_object.column_names.each do |name|
        if  class_object.columns_hash[name].type == :string || class_object.columns_hash[name].type == :text
            query= "#{table_name}.#{name} ILIKE :search OR "
            chosen_query = chosen_query.concat(query) 
        end
      end
      chosen_query
    
    end
   

    private def build_geojson
      
      {
        type: "FeatureCollection",
        features: @ready_buildings
      }
      
    end

    private def make_feature(record)
      
      {
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

    

  end
end