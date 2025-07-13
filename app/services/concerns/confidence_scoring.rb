# frozen_string_literal: true

module ConfidenceScoring
  CONFIDENCE_SCORES = {
    direct: 100,    # Match on the searched object itself
    child: 10,      # Match on a child/related object
    distant: 1      # Match on distant relationships
  }.freeze

  def calculate_building_confidence(building, search_term, year)
    search_pattern = search_term.downcase
    confidence = 0
    match_details = []

    # Direct building matches (100 points)
    building_matches = check_direct_building_matches(building, search_pattern)
    if building_matches.any?
      confidence += CONFIDENCE_SCORES[:direct]
      match_details.concat(building_matches)
    end

    # Address matches (100 points - considered direct)
    address_matches = check_address_matches(building, search_pattern)
    if address_matches.any?
      confidence += CONFIDENCE_SCORES[:direct]
      match_details.concat(address_matches)
    end

    # Child relationship matches (10 points each)
    child_matches = check_child_matches(building, search_pattern, year)
    child_matches.each do |match|
      confidence += CONFIDENCE_SCORES[:child]
      match_details << match
    end

    # Distant relationship matches (1 point each)
    distant_matches = check_distant_matches(building, search_pattern, year)
    distant_matches.each do |match|
      confidence += CONFIDENCE_SCORES[:distant]
      match_details << match
    end

    { confidence: confidence, match_details: match_details }
  end

  private

  def check_direct_building_matches(building, search_pattern)
    matches = []
    
    Building.column_names.each do |column|
      value = building.send(column)
      if value.to_s.downcase.include?(search_pattern)
        matches << { type: 'building', field: column, value: value }
      end
    end

    # Check rich text description
    if building.rich_text_description&.body&.to_s&.downcase&.include?(search_pattern)
      matches << { type: 'building', field: 'rich_description', value: 'rich_text_match' }
    end

    matches
  end

  def check_address_matches(building, search_pattern)
    matches = []
    
    building.addresses.each do |address|
      Address.column_names.each do |column|
        value = address.send(column)
        if value.to_s.downcase.include?(search_pattern)
          matches << { type: 'address', field: column, value: value }
        end
      end
    end

    matches
  end

  def check_child_matches(building, search_pattern, _year)
    matches = []

    # Photos
    building.photos.each do |photo|
      if photo.searchable_text&.downcase&.include?(search_pattern)
        matches << { type: 'photo', field: 'searchable_text', value: photo.searchable_text }
      end
    end

    # Videos
    building.videos.each do |video|
      if video.searchable_text&.downcase&.include?(search_pattern)
        matches << { type: 'video', field: 'searchable_text', value: video.searchable_text }
      end
    end

    # Audios
    building.audios.each do |audio|
      if audio.searchable_text&.downcase&.include?(search_pattern)
        matches << { type: 'audio', field: 'searchable_text', value: audio.searchable_text }
      end
    end

    # Narratives
    building.narratives.each do |narrative|
      Narrative.column_names.each do |column|
        value = narrative.send(column)
        if value.to_s.downcase.include?(search_pattern)
          matches << { type: 'narrative', field: column, value: value }
        end
      end

      # Check rich text in narratives
      if narrative.rich_text_story&.body&.to_s&.downcase&.include?(search_pattern)
        matches << { type: 'narrative', field: 'rich_text_story', value: 'rich_text_match' }
      end
      if narrative.rich_text_sources&.body&.to_s&.downcase&.include?(search_pattern)
        matches << { type: 'narrative', field: 'rich_text_sources', value: 'rich_text_match' }
      end
    end

    matches
  end

  def check_distant_matches(building, search_pattern, year)
    matches = []

    # People associated with building for the year
    people_association = building.send("people_#{year}")
    people_association.each do |person|
      Person.column_names.each do |column|
        value = person.send(column)
        if value.to_s.downcase.include?(search_pattern)
          matches << { type: 'person', field: column, value: value }
        end
      end

      # Person's media
      person.photos.each do |photo|
        if photo.searchable_text&.downcase&.include?(search_pattern)
          matches << { type: 'person_photo', field: 'searchable_text', value: photo.searchable_text }
        end
      end

      person.videos.each do |video|
        if video.searchable_text&.downcase&.include?(search_pattern)
          matches << { type: 'person_video', field: 'searchable_text', value: video.searchable_text }
        end
      end

      person.audios.each do |audio|
        if audio.searchable_text&.downcase&.include?(search_pattern)
          matches << { type: 'person_audio', field: 'searchable_text', value: audio.searchable_text }
        end
      end

      # Person's documents
      person.documents.each do |document|
        Document.column_names.each do |column|
          value = document.send(column)
          if value.to_s.downcase.include?(search_pattern)
            matches << { type: 'person_document', field: column, value: value }
          end
        end
      end

      # Person's narratives
      person.narratives.each do |narrative|
        Narrative.column_names.each do |column|
          value = narrative.send(column)
          if value.to_s.downcase.include?(search_pattern)
            matches << { type: 'person_narrative', field: column, value: value }
          end
        end
      end
    end

    # Census records for the year
    census_records = building.send("census#{year}_records")
    census_class = "Census#{year}Record".constantize
    census_records.each do |record|
      census_class.column_names.each do |column|
        value = record.send(column)
        if value.to_s.downcase.include?(search_pattern)
          matches << { type: 'census_record', field: column, value: value }
        end
      end
    end

    matches
  end
end
