# frozen_string_literal: true

class PersonJsonLdSerializer < ApplicationSerializer
  def serializable_hash
    {
      '@context' => 'https://schema.org',
      '@type' => 'Person',
      '@id' => "#{object.canonical_url}#person",
      'url' => object.canonical_url,
      'identifier' => object.id.to_s,
      'name' => object.name.presence,
      'description' => object.description,
      'birthDate' => date_year(object.birth_year),
      'deathDate' => date_year(object.death_year),
      'subjectOf' => source_documents.presence,
    }.compact
  end

  private

  def date_year(year)
    format('%04d', year) if year&.between?(1, 9999)
  end

  def source_documents
    object.source_links.map do |source|
      {
        '@type' => 'CreativeWork',
        '@id' => "#{source[:url]}#census-record",
        'url' => source[:url],
        'name' => "#{source[:year]} census record",
      }
    end
  end
end
