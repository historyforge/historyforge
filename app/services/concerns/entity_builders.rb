# frozen_string_literal: true

module EntityBuilders
  extend ActiveSupport::Concern

  def build_person_hash(person, year, include_related: true)
    return nil if person.nil?

    person_hash = {
      id: person.id,
      age: person.age_in_year(year.to_i) || person.try("census#{year}_record")&.age,
      birth_year: person.birth_year,
      description: person.description,
      gender: person.sex,
      is_birth_year_estimated: person.is_birth_year_estimated,
      is_pob_estimated: person.is_pob_estimated,
      name_prefix: person.name_prefix,
      name_suffix: person.name_suffix,
      name: person.searchable_name,
      notes: person.notes,
      place_of_birth: person.pob,
      race: person.race,
      sortable_name: person.sortable_name,
      year:
    }

    census_records = get_census_records_for_person(person, year)
    return nil if census_records.empty?

    person_hash[:properties] = {
      census_records: census_records.map { |record| build_census_record_hash(record, year) }
    }

    if include_related

      person_hash[:properties] = {
        documents: person.documents.map { |doc| build_document_hash(doc, year, include_related: false) },
        stories: person.narratives.map { |n| build_narrative_hash(n, year, include_related: false) },
        audios: person.audios.map { |a| build_audio_hash(a, year, include_related: false) },
        videos: person.videos.map { |v| build_video_hash(v, year, include_related: false) },
        photos: person.photos.map { |p| build_photo_hash(p, year, include_related: false) },
        buildings: person.buildings.map { |b| build_building_hash(b, year, include_related: false) }
      }
    end

    person_hash
  end

  def build_building_hash(building, year, include_related: true)
    return nil if building.nil?

    building = building.decorate if building.respond_to?(:decorate)

    parent = get_parent_for_building(Building)

    building_hash = {
      id: building.id,
      address: building.primary_street_address.gsub(/\s+/, ' ').strip,
      architects: building.architects,
      block_number: building.block_number,
      building_types: building.building_type,
      description_name: building.object.description&.name,
      description: building.object.description&.body&.to_html,
      frame: building.frame,
      historical_addresses: building.historical_addresses,
      latitude: building.latitude,
      lining: building.lining,
      locality: building.locality,
      location: building.coordinates,
      longitude: building.longitude,
      name: building.name,
      notes: building.notes,
      photo: building.photos&.first&.data_uri,
      parent:,
      rich_description_name: building.rich_text_description.name,
      rich_description: building.rich_text_description.body,
      stories: building.stories,
      year_earliest: building.year_earliest,
      year_latest: building.year_latest,
      year_split_from_parent: building.hive_year,
      year:
    }

    if include_related
      census_records = get_census_records_for_building(building, year)
      people = get_people_for_building(building, year)

      # Skip if there are no census records for this year (for strict mode)
      return nil if census_records.empty? && should_skip_empty_census?(year)

      building_hash[:properties] = {
        census_records: census_records.map { |record| build_census_record_hash(record, year) },
        people: people.map { |p| build_person_hash(p, year, include_related: false) },
        stories: building.narratives.map { |n| build_narrative_hash(n, year, include_related: false) },
        photos: building.photos.map { |p| build_photo_hash(p, year, include_related: false) },
        audios: building.audios.map { |a| build_audio_hash(a, year, include_related: false) },
        videos: building.videos.map { |v| build_video_hash(v, year, include_related: false) },
        documents: building.documents.map { |d| build_document_hash(d, year, include_related: false) },
        addresses: building.addresses.map(&:as_json)
      }
    end

    building_hash
  end

  def build_photo_hash(photo, year, include_related: true)
    return nil if photo.nil?

    photo_hash = {
      id: photo.id,
      caption: photo.caption,
      content_type: photo.file_attachment&.content_type,
      creator: photo.creator,
      data_uri: photo.data_uri,
      date_of_original: photo.date_text,
      description: photo.description,
      latitude: photo.latitude,
      location: photo.location,
      longitude: photo.longitude,
      notes: photo.notes,
      type: 'photo',
      URL: photo.file_attachment.present? ? sanitize_url(rails_blob_url(photo.file_attachment, host: ENV.fetch('BASE_URL', nil))) : nil,
      year:
    }

    if include_related
      census_records = get_census_records_for_media(photo, year)
      return nil if census_records.empty?

      photo_hash[:properties] = {
        people: photo.people.map { |p| build_person_hash(p, year, include_related: false) },
        census_records: census_records.map { |record| build_census_record_hash(record, year) },
        buildings: photo.buildings.map { |b| build_building_hash(b, year, include_related: false) }
      }
    end

    photo_hash
  end

  def build_video_hash(video, year, include_related: true)
    return nil if video.nil?

    video_hash = {
      id: video.id,
      caption: video.caption,
      creator: video.creator,
      data_uri: video.data_uri,
      date_of_original: video.date_text,
      description: video.description,
      duration: video.duration,
      file_size: video.file_size,
      height: video.height,
      latitude: video.latitude,
      location: video.location,
      longitude: video.longitude,
      notes: video.notes,
      processed_at: video.processed_at,
      thumbnail_processed_at: video.thumbnail_processed_at,
      type: 'video',
      URL: video.remote_url,
      width: video.width,
      year:
    }

    if include_related
      census_records = get_census_records_for_media(video, year)
      return nil if census_records.empty?

      video_hash[:properties] = {
        people: video.people.map { |p| build_person_hash(p, year, include_related: false) },
        census_records: census_records.map { |record| build_census_record_hash(record, year) },
        buildings: video.buildings.map { |b| build_building_hash(b, year, include_related: false) }
      }
    end

    video_hash
  end

  def build_audio_hash(audio, year, include_related: true)
    return nil if audio.nil?

    audio_hash = {
      id: audio.id,
      caption: audio.caption,
      creator: audio.creator,
      data_uri: audio.data_uri,
      date_of_original: audio.date_text,
      description: audio.description,
      duration: audio.duration,
      file_size: audio.file_size,
      identifier: audio.identifier,
      latitude: audio.latitude,
      location: audio.location,
      longitude: audio.longitude,
      notes: audio.notes,
      processed_at: audio.processed_at,
      type: 'audio',
      URL: audio.remote_url,
      year:
    }

    if include_related
      census_records = get_census_records_for_media(audio, year)
      return nil if census_records.empty?

      audio_hash[:properties] = {
        people: audio.people.map { |p| build_person_hash(p, year, include_related: false) },
        census_records: census_records.map { |record| build_census_record_hash(record, year) },
        buildings: audio.buildings.map { |b| build_building_hash(b, year, include_related: false) }
      }
    end

    audio_hash
  end

  def build_narrative_hash(narrative, year, include_related: true)
    return nil if narrative.nil?

    narrative_hash = {
      id: narrative.id,
      date_of_original: narrative.date_text,
      notes: narrative.notes,
      source_name: narrative.sources.name,
      source: narrative.sources.body,
      story_name: narrative.story.name,
      story: narrative.story.body,
      type: 'story',
      weight: narrative.weight,
      year:
    }

    if include_related
      census_records = get_census_records_for_media(narrative, year)
      return nil if census_records.empty?

      narrative_hash[:properties] = {
        people: narrative.people.map { |p| build_person_hash(p, year, include_related: false) },
        census_records: census_records.map { |record| build_census_record_hash(record, year) },
        buildings: narrative.buildings.map { |b| build_building_hash(b, year, include_related: false) }
      }
    end

    narrative_hash
  end

  def build_document_hash(document, year, include_related: true)
    return nil if document.nil?

    document_hash = {
      id: document.id,
      available_to_public: document.available_to_public,
      category: document.document_category&.name,
      content_type: document.file_attachment&.blob&.content_type,
      data_uri: document.data_uri,
      description: document.description,
      name: document.name,
      position: document.position,
      searchable_text: document.respond_to?(:searchable_text) ? document.searchable_text : nil,
      URL: document.file_attachment&.blob.present? ? sanitize_url(rails_blob_url(document.file_attachment, host: ENV.fetch('BASE_URL', nil))) : nil,
      url: document.url,
      year: year
    }

    if include_related
      census_record_names = ['census record', 'census', 'census records', 'census_records', 'census_record']
      is_census_document = census_record_names.include?(document.document_category&.name&.downcase)

      if is_census_document
        census_records = get_census_records_for_media(document, year)
        return nil if census_records.empty?
      end

      document_hash[:properties] = {
        people: document.people.map { |p| build_person_hash(p, year, include_related: false) },
        census_records: is_census_document ? get_census_records_for_media(document, year).map { |record| build_census_record_hash(record, year) } : [],
        buildings: document.buildings.map { |b| build_building_hash(b, year, include_related: false) }
      }
    end

    document_hash
  end

  def build_census_record_hash(census_record, year)
    return nil if census_record.nil?

    census_record = census_record.decorate if census_record.respond_to?(:decorate)

    {
      id: census_record.id,
      age_months: census_record.age_months,
      age: census_record.age,
      apartment_number: census_record.apartment_number,
      attended_school: census_record.attended_school,
      building_id: census_record.building_id,
      can_read: census_record.can_read,
      can_speak_english: census_record.can_speak_english,
      can_write: census_record.can_write,
      census_person_id: census_record.census_person_id,
      city: census_record.city,
      county: census_record.county,
      created_at: census_record.created_at,
      dwelling_number: census_record.dwelling_number,
      employment_code: census_record.employment_code,
      employment: census_record.employment,
      family_id: census_record.family_id,
      farm_or_house: census_record.farm_or_house,
      farm_schedule: census_record.farm_schedule,
      first_name: census_record.first_name,
      foreign_born: census_record.foreign_born,
      gender: census_record.gender,
      histid: census_record.histid,
      industry: census_record.industry,
      institution: census_record.institution,
      last_name: census_record.last_name,
      locality_id: census_record.locality_id,
      marital_status: census_record.marital_status,
      middle_name: census_record.middle_name,
      mortgage: census_record.mortgage,
      mother_tongue_father: census_record.mother_tongue_father,
      mother_tongue_mother: census_record.mother_tongue_mother,
      mother_tongue: census_record.mother_tongue,
      name_prefix: census_record.name_prefix,
      name_suffix: census_record.name_suffix,
      naturalized_alien: census_record.naturalized_alien,
      notes: census_record.notes,
      occupation: census_record.occupation,
      owned_or_rented: census_record.owned_or_rented,
      person_id: census_record.person_id,
      pob_father: census_record.pob_father,
      pob_mother: census_record.pob_mother,
      pob: census_record.pob,
      provisional: census_record.provisional,
      race: census_record.race,
      relation_to_head: census_record.relation_to_head,
      searchable_name: census_record.searchable_name,
      scope: census_record.census_scope,
      sex: census_record.sex,
      sortable_name: census_record.sortable_name,
      state: census_record.state,
      street_house_number: census_record.street_house_number,
      street_name: census_record.street_name,
      street_prefix: census_record.street_prefix,
      street_suffix: census_record.street_suffix,
      taker_error: census_record.taker_error,
      updated_at: census_record.updated_at,
      year_immigrated: census_record.year_immigrated,
      year_naturalized: census_record.year_naturalized,
      year:
    }
  end

  def build_address_hash(address, year)
    # If address is nil, return nil
    return nil if address.nil?

    address = address.decorate if address.respond_to?(:decorate)

    {
      id: address.id,
      is_primary: address.is_primary,
      name: address.name,
      searchable_text: address.searchable_text.gsub(/\s+/, ' ').strip,
      prefix: address.prefix,
      street_house_number: address.street_house_number,
      street_name: address.street_name,
      suffix: address.suffix,
      city: address.city,
      state: address.state,
      zip: address.zip,
      year:
    }
  end

  private

  def get_census_records_for_person(person, year)
    person.send("census#{year}_records")
  rescue NoMethodError
    []
  end

  def get_census_records_for_building(building, year)
    building.send("census#{year}_records")
  rescue NoMethodError
    []
  end

  def get_people_for_building(building, year)
    building.send("people_#{year}")
  rescue NoMethodError
    []
  end

  def get_parent_for_building(building)
    building.send(:parent)
  rescue NoMethodError
    []
  end

  def get_census_records_for_media(media_item, year)
    media_item.people.flat_map { |p| p.send("census#{year}_records") }
  end

  def should_skip_empty_census?(_year)
    # Override in controllers that need strict mode
    false
  end

  def sanitize_url(url)
    return nil if url.blank?

    url.gsub('/admin/admin/', '/admin/')
  end
end
