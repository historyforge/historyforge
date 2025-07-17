# frozen_string_literal: true

module Api
  class JsonController < ApplicationController
    include EntityBuilders
    include SearchService
    include ConfidenceScoring

    def json

      search_term = params[:search]

      if search_term.blank?
        render_empty_results
        return
      end

      results = build_search_results(search_term)
      counts = calculate_counts(results)

      render json: {
        results: results,
        count: counts
      }
    end

    private

    def build_search_results(search_term)
      all_results = {
        buildings: [],
        people: [],
        documents: [],
        stories: [],
        media: []
      }

      SEARCH_YEARS.each do |year|
        year_results = search_for_year(search_term, year)

        all_results[:buildings].concat(year_results[:buildings])
        all_results[:people].concat(year_results[:people])
        all_results[:documents].concat(year_results[:documents])
        all_results[:stories].concat(year_results[:stories])
        all_results[:media].concat(year_results[:media])
      end

      # Remove duplicates by building ID, keeping the first occurrence
      seen_building_ids = Set.new
      all_results[:buildings] = all_results[:buildings].filter do |building|
        if seen_building_ids.include?(building[:id])
          false
        else
          seen_building_ids.add(building[:id])
          true
        end
      end

      # Sort buildings by confidence score (descending)
      all_results[:buildings] = all_results[:buildings].sort_by { |building| -building[:confidence_score] }

      # Similar deduplication for other entity types
      seen_people_ids = Set.new
      all_results[:people] = all_results[:people].filter do |person|
        if seen_people_ids.include?(person[:id])
          false
        else
          seen_people_ids.add(person[:id])
          true
        end
      end

      seen_document_ids = Set.new
      all_results[:documents] = all_results[:documents].filter do |document|
        if seen_document_ids.include?(document[:id])
          false
        else
          seen_document_ids.add(document[:id])
          true
        end
      end

      seen_story_ids = Set.new
      all_results[:stories] = all_results[:stories].filter do |story|
        if seen_story_ids.include?(story[:id])
          false
        else
          seen_story_ids.add(story[:id])
          true
        end
      end

      seen_media_ids = Set.new
      all_results[:media] = all_results[:media].filter do |media|
        if seen_media_ids.include?(media[:id])
          false
        else
          seen_media_ids.add(media[:id])
          true
        end
      end

      all_results
    end

    def search_for_year(search_term, year)
      # Search all entity types
      buildings = search_buildings(search_term, year)
      people = search_people(search_term, year)
      documents = search_documents(search_term, year)
      narratives = search_narratives(search_term, year)
      photos = search_photos(search_term, year)
      videos = search_videos(search_term, year)
      audios = search_audios(search_term, year)

      # Build hashes with confidence scores
      building_hashes = buildings.filter_map do |b| 
        hash = build_building_hash(b, year)
        if hash
          confidence_data = calculate_building_confidence(b, search_term, year)
          hash[:confidence_score] = confidence_data[:confidence]
          hash[:match_details] = confidence_data[:match_details] if Rails.env.development?
          hash
        end
      end
      people_hashes = people.filter_map { |p| build_person_hash(p, year) }
      document_hashes = documents.filter_map { |d| build_document_hash(d, year) }
      narrative_hashes = narratives.filter_map { |n| build_narrative_hash(n, year) }
      photo_hashes = photos.filter_map { |p| build_photo_hash(p, year) }
      video_hashes = videos.filter_map { |v| build_video_hash(v, year) }
      audio_hashes = audios.filter_map { |a| build_audio_hash(a, year) }

      {
        buildings: building_hashes,
        people: people_hashes,
        documents: document_hashes,
        stories: narrative_hashes,
        media: photo_hashes + video_hashes + audio_hashes
      }
    end

    def calculate_counts(results)
      year_counts = {}

      SEARCH_YEARS.each do |year|
        year_buildings = results[:buildings].select { |b| b[:year] == year }
        year_people = results[:people].select { |p| p[:year] == year }
        year_documents = results[:documents].select { |d| d[:year] == year }
        year_stories = results[:stories].select { |s| s[:year] == year }
        year_media = results[:media].select { |m| m[:year] == year }

        census_records_count = count_census_records(year_documents)

        year_counts[year] = {
          buildings: year_buildings.count,
          people: year_people.count,
          documents: year_documents.count,
          census_records: census_records_count,
          stories: year_stories.count,
          media: year_media.count,
          year: year
        }
      end

      # Add total counts
      year_counts['Total'] = {
        buildings: results[:buildings].count,
        people: results[:people].count,
        documents: results[:documents].count,
        census_records: year_counts.values.sum { |counts| counts[:census_records] },
        stories: results[:stories].count,
        media: results[:media].count,
        year: 'Total'
      }

      year_counts.values
    end

    def count_census_records(documents)
      census_record_names = %w[census record census_records census_record]
      documents.count { |doc| census_record_names.include?(doc[:category]&.downcase) }
    end

    def render_empty_results
      render json: {
        results: {
          buildings: [],
          people: [],
          documents: [],
          stories: [],
          media: []
        },
        count: []
      }
    end
  end
end
