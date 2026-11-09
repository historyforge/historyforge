# frozen_string_literal: true

module People
  # Builds a short account from authorized narrative evidence.
  class CensusSummary
    Result = Data.define(:paragraph, :sources)
    GENERIC_INDUSTRIES = ['general practice', 'local', 'own office'].freeze
    PRONOUNS = { 'F' => 'she', 'M' => 'he' }.freeze
    CHILDHOOD_AGES = %w[one two three four five six seven eight nine ten eleven twelve thirteen fourteen fifteen sixteen seventeen].freeze

    def self.call(name:, sex:, observations:)
      new(name:, sex:, observations:).call
    end

    def initialize(name:, sex:, observations:)
      @name = name
      @pronoun = PRONOUNS.fetch(sex, 'they')
      @observations = observations
    end

    def call
      continuity = Continuity.call(observations: @observations)
      return unless continuity

      jobs = select_occupations(continuity.occupations)
      extended = jobs.size > 3
      family_first = continuity.households.any? && jobs.none? { |group| group.first.occupation } &&
                     continuity.households.flatten.any? { |entry| childhood_age(entry) }
      sentences = []
      sentences << household_sentence(continuity.households, @name) if family_first
      if extended
        sentences << occupation_sentence(jobs.first(2), @name)
        sentences << occupation_sentence(jobs.drop(2), @pronoun.capitalize)
      elsif jobs.any?
        sentences << occupation_sentence(jobs, family_first ? @pronoun.capitalize : @name)
      end
      if continuity.residences.any?
        subject = sentences.empty? ? @name : @pronoun.capitalize
        sentences.concat(residence_sentences(continuity.residences, subject, childhood: sentences.empty?))
      end
      if continuity.households.any? && !family_first
        subject = sentences.empty? ? @name : @pronoun.capitalize
        sentences << household_sentence(continuity.households, subject)
      end

      paragraph = if extended && sentences.size > 2
                    [sentences.first(2).join(' '), sentences.drop(2).join(' ')].join("\n\n")
                  else
                    sentences.join(' ')
                  end
      Result.new(paragraph:, sources: continuity.sources)
    end

    private

    def occupation_sentence(groups, subject)
      if groups.all? { |group| group.first.occupation }
        titles = groups.map { |group| dated_occupation(group) }
        return "#{subject} worked as #{titles.to_sentence}."
      end

      clauses = groups.map.with_index do |group, index|
        actor = index.zero? ? subject : @pronoun
        if group.first.occupation
          "#{actor} worked as #{dated_occupation(group)}"
        else
          age = childhood_age(group.first) if index.zero? && group.one?
          actor = @pronoun if age && actor == @pronoun.capitalize
          "#{("At #{age}, " if age)}#{actor} #{past_be(actor)} #{group.first.activity} #{dates(group)}"
        end
      end
      "#{clauses.to_sentence(two_words_connector: ', and ')}."
    end

    def select_occupations(groups)
      # A job can recur after a gap or a different job. Keep its observed dates.
      grouped = groups.group_by { |group| group.first.occupation ? Occupation.label(group).downcase : group }
      jobs = grouped.values.map { |entries| entries.flatten.sort_by { |entry| entry.record.year } }
      return jobs if jobs.size <= 3

      middle = jobs[1...-1].select { |group| group.many? || industry_example(group) }
      middle = middle.sort_by { |group| [-group.size, group.first.record.year] }.first(3)
      [jobs.first, *middle.sort_by { |group| group.first.record.year }, jobs.last]
    end

    def dated_occupation(group)
      label = Occupation.label(group)
      title = "“#{label}” #{dates(group)}"
      example = industry_example(group)
      return title unless example

      # Give one dated industry example. Only leave the date implicit when every row supports it.
      context = "industry “#{example.industry}”"
      context += " in #{example.record.year}" unless group.all? { |entry| example.industry.casecmp?(entry.industry.to_s) }
      "#{title} (#{context})"
    end

    def industry_example(group)
      label = Occupation.label(group)
      group.find { |entry| specific_industry?(entry.industry, label) } if label
    end

    def specific_industry?(industry, occupation)
      return false if industry.nil? || industry.casecmp?(occupation) || GENERIC_INDUSTRIES.include?(industry.downcase)

      !industry.casecmp?('medical') || !%w[doctor physician].include?(occupation.downcase)
    end

    def residence_sentences(groups, subject, childhood:)
      localities, streets = groups.partition { |group| group.first.residence.start_with?('in ') }
      entries = groups.flatten
      if localities.empty? || streets.empty?
        return [residence_sentence(groups, subject, childhood:, entries:)]
      end

      locality_details = localities.map { |group| "in #{display_place(group.first, entries)} #{dates(group)}" }
      if localities.first.first.record.year < streets.first.first.record.year
        ["#{subject} #{past_be(subject)} recorded #{locality_details.to_sentence}.",
         residence_sentence(streets, @pronoun.capitalize, childhood: false, entries:)]
      else
        [residence_sentence(streets, subject, childhood:, entries:),
         "#{@pronoun.capitalize} #{past_be(@pronoun)} recorded #{locality_details.to_sentence}."]
      end
    end

    def residence_sentence(groups, subject, childhood:, entries:)
      if groups.one?
        group = groups.first
        entry = group.first
        location = residence_label(entry, display_place(entry, entries))
        age = childhood_age(entry) if childhood && group.one?
        return "#{("At #{age}, " if age)}#{subject} lived #{location} #{dates(group)}." if group.one?

        return "#{subject} lived #{location} #{dates(group)}."
      end

      street_entries = groups.flatten
      highlight = groups.max_by do |group|
        [group.first.address_key && group.many? ? group.size : 0, group.last.record.year]
      end
      entry = highlight.first
      location = residence_label(entry, display_place(entry, entries))
      places = street_entries.select(&:place).uniq { |row| [row.record.locality_id, row.place, row.record.field_for(:state)] }
      roads = street_entries.filter_map { |row| row.road&.downcase }.uniq
      addresses = street_entries.filter_map(&:address_key).uniq
      number = entry.record.street_house_number
      if places.one? && roads.one? && entry.address_key && entry.address_key.last.nil? &&
         street_entries.any? { |row| row.residence.start_with?('on ') }
        return "#{subject} lived on #{entry.road} in #{display_place(entry, entries)}, " \
               "at number #{number} #{dates(highlight)}."
      end

      if places.one? && addresses.many? && entry.address_key
        address = entry.residence.delete_prefix('at ').delete_suffix(" in #{entry.place}")
        return "#{subject} lived at more than one address in #{display_place(entry, entries)}, " \
               "including #{address} #{dates(highlight)}."
      end

      pattern = residence_pattern(places, addresses, roads)
      "#{subject} lived #{pattern ? "#{pattern}, including " : ''}#{location} #{dates(highlight)}."
    end

    def residence_pattern(places, addresses, roads)
      if places.many?
        names = places.map { |entry| display_place(entry, places) }
        return "in #{names.to_sentence}" if names.size == 2 && names.uniq.size == 2
        return 'in several localities' if names.uniq.size > 1
      end

      return 'at different addresses' if addresses.many?

      'on different streets' if roads.many?
    end

    def display_place(entry, entries)
      place = entry.place
      return unless place

      state = entry.record.field_for(:state)
      if state.present? && entries.any? { |other| other.place == place && other.record.field_for(:state).present? &&
                                                  other.record.field_for(:state) != state }
        return "#{place}, #{state}"
      end

      short = place.delete_prefix('City of ')
      entries.any? { |other| other.place == "Town of #{short}" } ? place : short
    end

    def residence_label(entry, place)
      return entry.residence if place == entry.place

      entry.residence.delete_suffix("in #{entry.place}") + "in #{place}"
    end

    def household_sentence(groups, subject)
      first, last = groups.map { |group| group.first.household }
      same_member = last && first.member.person_id.present? && first.member.person_id == last.member.person_id
      if same_member && (first.role != last.role || first.role.nil?)
        return "#{subject} shared a census household with #{first.name} #{dates(groups.flatten)}."
      end

      groups = [groups.flatten] if same_member
      terms = groups.map { |group| established_kin(group) }
      # Two different people with the same relationship may reflect a change or conflicting evidence.
      if terms.size == 2 && (terms.first == terms.last || (terms - %w[wife husband spouse]).empty?)
        terms = Array.new(groups.size)
      end
      if terms.none? && first.role
        labels = groups.map do |group|
          relationship = group.first.household
          "the #{relationship.role} of #{relationship.name} #{dates(group)}"
        end
        return "#{subject} #{past_be(subject)} listed as #{labels.to_sentence}."
      end

      clauses = groups.zip(terms).map.with_index do |(group, term), index|
        relationship = group.first.household
        actor = index.zero? ? subject : @pronoun
        if term
          owner = if actor.casecmp?(@pronoun)
                    { 'he' => 'his', 'she' => 'her', 'they' => 'their' }.fetch(@pronoun)
                  else
                    "#{actor}’s"
                  end
          "#{index.zero? ? owner.sub(/\A./, &:upcase) : owner} #{term} was #{relationship.name}"
        elsif relationship.role
          "#{actor} #{past_be(actor)} listed as the #{relationship.role} of #{relationship.name} #{dates(group)}"
        else
          "#{actor} shared a census household with #{relationship.name} #{dates(group)}"
        end
      end
      "#{clauses.to_sentence(two_words_connector: ', and ')}."
    end

    def established_kin(group)
      relationships = group.map(&:household)
      first = relationships.first
      return unless first.member.person_id.present? && first.kin && !first.role.start_with?('step') &&
                    !first.kin.start_with?('step')

      return first.kin if relationships.all? { |relationship| relationship.kin == first.kin }

      Evidence::GENDERED_KIN.keys.find do |neutral|
        terms = Evidence::GENDERED_KIN.fetch(neutral).values + [neutral]
        relationships.all? { |relationship| terms.include?(relationship.kin) }
      end
    end

    def dates(group)
      years = group.map { |entry| entry.record.year }.to_sentence
      "in #{'both ' if group.size == 2}#{years}"
    end

    def childhood_age(entry)
      age = entry.record.age
      CHILDHOOD_AGES.fetch(age - 1) if age&.between?(1, CHILDHOOD_AGES.length)
    end

    def past_be(subject)
      subject.casecmp?('they') ? 'were' : 'was'
    end
  end
end
