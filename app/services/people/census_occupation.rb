# frozen_string_literal: true

module People
  # Matches a small set of recorded occupation variants.
  module CensusOccupation
    COMPOUND_OCCUPATIONS = %w[
      bookbinder bookkeeper boatbuilder bricklayer cabinetmaker glassblower gunsmith hairdresser housekeeper
      papermaker schoolteacher steamfitter stonecutter toolmaker watchmaker
    ].freeze
    OCCUPATION_ALIASES = { 'attorney' => 'lawyer', 'medical doctor' => 'physician' }.freeze
    CONTEXTUAL_OCCUPATIONS = {
      %w[doctor physician] => ['physician', /\A(?:clinic|hospital|medical|medical practice|medicine|practice of medicine|doctor of medicine|physician['’]s office)\z/],
      %w[schoolteacher teacher] => ['teacher', /\bschools?\b/],
      %w[teacher teaching] => ['teacher', /\b(?:schools?|universit(?:y|ies)|colleges?)\b/],
    }.freeze

    def self.equivalent?(first, later)
      first_title = occupation_key(first.occupation)
      later_title = occupation_key(later.occupation)
      return false unless first_title && later_title
      return true if first_title == later_title

      rule = CONTEXTUAL_OCCUPATIONS[[first_title, later_title].sort]
      industry = first.industry&.downcase
      rule && industry && industry == later.industry&.downcase && rule.last.match?(industry)
    end

    def self.label(group)
      titles = group.map { |entry| occupation_key(entry.occupation) }.uniq.sort
      preferred = CONTEXTUAL_OCCUPATIONS[titles]&.first
      group.find { |entry| preferred && entry.occupation.casecmp?(preferred) }&.occupation || group.first.occupation
    end

    def self.shared_industry(group)
      industry = group.first.industry
      industry if industry && group.all? { |entry| industry.casecmp?(entry.industry.to_s) }
    end

    def self.occupation_key(occupation)
      return unless occupation

      title = occupation.downcase
      joined = title.delete(' -')
      return joined if COMPOUND_OCCUPATIONS.include?(joined)

      OCCUPATION_ALIASES.fetch(title, title)
    end
    private_class_method :occupation_key
  end
end
