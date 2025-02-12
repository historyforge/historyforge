module Api
  class SearchController < ApplicationController
   
    def search
      @census_query = ""
      @building_query = ""
      Census1920Record.column_names.each do |name|
        if  Census1920Record.columns_hash[name].type == :string || Census1920Record.columns_hash[name].type == :text
            query= "census_1920_records.#{name} LIKE :search OR "
            @census_query = @census_query.concat(query) 
        end
      end

     
      Building.column_names.each do |name|
        if  Building.columns_hash[name].type == :string || Building.columns_hash[name].type == :text
            query= "buildings.#{name} LIKE :search OR "
            @building_query = @building_query.concat(query) 
        end
      end
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