# frozen_string_literal: true

module SearchService
  extend ActiveSupport::Concern

  SEARCH_YEARS = %w[1910 1920].freeze

  def search_buildings_for_year(target, year)
    return [] if target.blank?

    search_pattern = "%#{target}%"
    building_ids = []

    # Direct building search across all columns (like legacy API)
    query_parts = Building.column_names.map { |col| "buildings.#{col}::varchar ILIKE ?" }
    search_values = [search_pattern] * Building.column_names.count

    building_ids.concat(
      Building.where(query_parts.join(' OR '), *search_values)
              .pluck(:id)
    )

    # Address search (comprehensive column search)
    address_query_parts = Address.column_names.map { |col| "addresses.#{col}::varchar ILIKE ?" }
    address_search_values = [search_pattern] * Address.column_names.count

    building_ids.concat(
      Building.joins(:addresses)
              .where(address_query_parts.join(' OR '), *address_search_values)
              .pluck(:id)
    )

    # Photo search
    building_ids.concat(
      Building.joins(:photos)
              .where('photographs.searchable_text ILIKE ?', search_pattern)
              .pluck(:id)
    )

    # Video search
    building_ids.concat(
      Building.joins(:videos)
              .where('videos.searchable_text ILIKE ?', search_pattern)
              .pluck(:id)
    )

    # Audio search
    building_ids.concat(
      Building.joins(:audios)
              .where('audios.searchable_text ILIKE ?', search_pattern)
              .pluck(:id)
    )

    # Narrative search (comprehensive column search)
    narrative_query_parts = Narrative.column_names.map { |col| "narratives.#{col}::varchar ILIKE ?" }
    narrative_search_values = [search_pattern] * Narrative.column_names.count

    building_ids.concat(
      Building.joins(:narratives)
              .where(narrative_query_parts.join(' OR '), *narrative_search_values)
              .pluck(:id)
    )

    # Rich text searches
    building_ids.concat(
      Building.joins(:rich_text_description)
              .where('action_text_rich_texts.body ILIKE ?', search_pattern)
              .pluck(:id)
    )

    building_ids.concat(
      Building.joins(narratives: :rich_text_story)
              .where('action_text_rich_texts.body ILIKE ?', search_pattern)
              .pluck(:id)
    )

    building_ids.concat(
      Building.joins(narratives: :rich_text_sources)
              .where('action_text_rich_texts.body ILIKE ?', search_pattern)
              .pluck(:id)
    )

    # People search for specific year (comprehensive column search)
    people_association = :"people_#{year}"
    person_query_parts = Person.column_names.map { |col| "people.#{col}::varchar ILIKE ?" }
    person_search_values = [search_pattern] * Person.column_names.count

    building_ids.concat(
      Building.joins(people_association)
              .where(person_query_parts.join(' OR '), *person_search_values)
              .pluck(:id)
    )

    # Census search for specific year (comprehensive column search)
    census_class = "Census#{year}Record".constantize
    census_association = :"census#{year}_records"
    census_query_parts = census_class.column_names.map { |col| "census_#{year}_records.#{col}::varchar ILIKE ?" }
    census_search_values = [search_pattern] * census_class.column_names.count

    building_ids.concat(
      Building.joins(census_association)
              .where(census_query_parts.join(' OR '), *census_search_values)
              .pluck(:id)
    )

    # People-related searches
    building_ids.concat(
      Building.joins(people_association => :photos)
              .where('photographs.searchable_text ILIKE ?', search_pattern)
              .pluck(:id)
    )

    building_ids.concat(
      Building.joins(people_association => :videos)
              .where('videos.searchable_text ILIKE ?', search_pattern)
              .pluck(:id)
    )

    building_ids.concat(
      Building.joins(people_association => :audios)
              .where('audios.searchable_text ILIKE ?', search_pattern)
              .pluck(:id)
    )

    building_ids.concat(
      Building.joins(people_association => :narratives)
              .where(narrative_query_parts.join(' OR '), *narrative_search_values)
              .pluck(:id)
    )

    # Document search through people
    doc_query_parts = Document.column_names.map { |col| "documents.#{col}::varchar ILIKE ?" }
    doc_search_values = [search_pattern] * Document.column_names.count

    building_ids.concat(
      Building.joins(people_association => :documents)
              .where(doc_query_parts.join(' OR '), *doc_search_values)
              .pluck(:id)
    )

    # Rich text through people narratives
    building_ids.concat(
      Building.joins(people_association => { narratives: :rich_text_story })
              .where('action_text_rich_texts.body ILIKE ?', search_pattern)
              .pluck(:id)
    )

    building_ids.concat(
      Building.joins(people_association => { narratives: :rich_text_sources })
              .where('action_text_rich_texts.body ILIKE ?', search_pattern)
              .pluck(:id)
    )

    building_ids.uniq
  end

  def search_buildings(search_term, year, require_coordinates: false)
    building_ids = search_buildings_for_year(search_term, year)
    return Building.none if building_ids.empty?

    query = Building.where(id: building_ids)
    query = query.where('lat IS NOT NULL AND lon IS NOT NULL') if require_coordinates

    query.includes(:narratives, :photos, :audios, :videos, :addresses,
                   :"people_#{year}", :"census#{year}_records",
                   :parent, parent: :addresses)
  end

  def search_people(search_term, year)
    return Person.none if search_term.blank?

    search_pattern = "%#{search_term}%"

    # Use comprehensive column search like legacy API
    query_parts = Person.column_names.map do |column_name|
      "people.#{column_name}::varchar ILIKE ?"
    end

    search_values = [search_pattern] * Person.column_names.count

    Person.where(query_parts.join(' OR '), *search_values)
          .includes(:"census#{year}_records", :photos, :videos, :audios,
                    :narratives, :documents, narratives: %i[rich_text_story rich_text_sources])
  end

  def search_photos(search_term, year)
    return Photograph.none if search_term.blank?

    search_pattern = "%#{search_term}%"
    Photograph.where('photographs.searchable_text ILIKE ?', search_pattern)
              .includes(:buildings, people: [:"census#{year}_records"])
  end

  def search_videos(search_term, year)
    return Video.none if search_term.blank?

    search_pattern = "%#{search_term}%"
    Video.where('videos.searchable_text ILIKE ?', search_pattern)
         .includes(:buildings, people: [:"census#{year}_records"])
  end

  def search_audios(search_term, year)
    return Audio.none if search_term.blank?

    search_pattern = "%#{search_term}%"
    Audio.where('audios.searchable_text ILIKE ?', search_pattern)
         .includes(:buildings, people: [:"census#{year}_records"])
  end

  def search_narratives(search_term, year)
    return Narrative.none if search_term.blank?

    search_pattern = "%#{search_term}%"
    narrative_ids = []

    # Direct narrative search
    narrative_ids.concat(
      Narrative.where('narratives.source ILIKE ? OR narratives.notes ILIKE ?',
                      search_pattern, search_pattern).pluck(:id)
    )

    # Rich text searches
    narrative_ids.concat(
      Narrative.joins(:rich_text_story)
               .where('action_text_rich_texts.body ILIKE ?', search_pattern).pluck(:id)
    )

    narrative_ids.concat(
      Narrative.joins(:rich_text_sources)
               .where('action_text_rich_texts.body ILIKE ?', search_pattern).pluck(:id)
    )

    narrative_ids = narrative_ids.uniq
    Narrative.where(id: narrative_ids)
             .includes(:rich_text_story, :rich_text_sources, people: [:"census#{year}_records"])
  end

  def search_documents(search_term, year)
    return Document.none if search_term.blank?

    # Use comprehensive column search like legacy API
    query_parts = Document.column_names.map do |column_name|
      "documents.#{column_name}::varchar ILIKE ?"
    end

    search_pattern = "%#{search_term}%"
    search_values = [search_pattern] * Document.column_names.count

    Document.where(query_parts.join(' OR '), *search_values)
            .includes(:document_category, :file_attachment, :buildings,
                      :people, people: :"census#{year}_records")
            .distinct
  end
end
