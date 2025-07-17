# frozen_string_literal: true

module EntityBuilders
  extend ActiveSupport::Concern

  def build_person_hash(person, year, include_related: true)
    entity = PersonEntity.build_from(person, year, include_related: include_related)
    entity&.to_h
  end

  def build_building_hash(building, year, include_related: true)
    entity = BuildingEntity.build_from(building, year, include_related: include_related)
    entity&.to_h
  end

  def build_photo_hash(photo, year, include_related: true)
    entity = PhotoEntity.build_from(photo, year, include_related: include_related)
    entity&.to_h
  end

  def build_video_hash(video, year, include_related: true)
    entity = VideoEntity.build_from(video, year, include_related: include_related)
    entity&.to_h
  end

  def build_audio_hash(audio, year, include_related: true)
    entity = AudioEntity.build_from(audio, year, include_related: include_related)
    entity&.to_h
  end

  def build_narrative_hash(narrative, year, include_related: true)
    entity = NarrativeEntity.build_from(narrative, year, include_related: include_related)
    entity&.to_h
  end

  def build_document_hash(document, year, include_related: true)
    entity = DocumentEntity.build_from(document, year, include_related: include_related)
    entity&.to_h
  end

  def build_census_record_hash(census_record, year)
    entity = CensusRecordEntity.build_from(census_record, year)
    entity&.to_h
  end

  def build_address_hash(address, year)
    entity = AddressEntity.build_from(address, year)
    entity&.to_h
  end

  private

  def should_skip_empty_census?(_year)
    # Override in controllers that need strict mode
    false
  end
end
