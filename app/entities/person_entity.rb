# frozen_string_literal: true

class PersonEntity < BaseEntity

  attribute :id, :integer
  attribute :age, :integer
  attribute :birth_year, :integer
  attribute :description, :string
  attribute :gender, :string
  attribute :is_birth_year_estimated, :boolean
  attribute :is_pob_estimated, :boolean
  attribute :name_prefix, :string
  attribute :name_suffix, :string
  attribute :name, :string
  attribute :notes, :string
  attribute :place_of_birth, :string
  attribute :race, :string
  attribute :sortable_name, :string
  attribute :year, :integer
  attribute :properties, default: {}

  def self.build_from(person, year, include_related: true)
    return nil if person.nil?

    entity = new(
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
      year: year
    )

    census_records = get_census_records_for_person(person, year)
    return nil if census_records.empty?

    entity.properties = {
      census_records: census_records.map { |record| CensusRecordEntity.build_from(record, year) }
    }

    if include_related
      entity.properties.merge!(
        documents: person.documents.filter_map { |doc| DocumentEntity.build_from(doc, year, include_related: false) },
        stories: person.narratives.filter_map { |n| NarrativeEntity.build_from(n, year, include_related: false) },
        audios: person.audios.filter_map { |a| AudioEntity.build_from(a, year, include_related: false) },
        videos: person.videos.filter_map { |v| VideoEntity.build_from(v, year, include_related: false) },
        photos: person.photos.filter_map { |p| PhotoEntity.build_from(p, year, include_related: false) },
        buildings: person.buildings.filter_map { |b| BuildingEntity.build_from(b, year, include_related: false) }
      )
    end

    entity
  end

  def to_h
    attributes.compact.tap do |hash|
      hash['properties'] = properties if properties.present?
    end
  end

  private

end
