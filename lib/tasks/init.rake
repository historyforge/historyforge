# frozen_string_literal: true

namespace :init do
  # Compatibility name for older administrator instructions.
  task new_admin_user: 'hf:create_admin'

  task build: :environment do
    Vocabulary.where(machine_name: 'relation_to_head').first_or_create { |model| model.name = 'Relation to Head' }
    Vocabulary.where(machine_name: 'pob').first_or_create { |model| model.name = 'Place of Birth' }
    Vocabulary.where(machine_name: 'language').first_or_create { |model| model.name = 'Language Spoken' }
  end

  task fixtures: :environment do
    require 'active_record/fixtures'
    ActiveRecord::FixtureSet.create_fixtures(Rails.root.join('db', 'fixtures'), 'occupation1930_codes')
  end

  task terms: :environment do
    Term.delete_all
    [
      ['Language Spoken', 'language'],
      ['Place of Birth', 'pob'],
      ['Relation to Head', 'relation_to_head']
    ].each do |item|
      file = File.open(Rails.root.join('db', "#{item[0]}.csv"))
      vocabulary = Vocabulary.find_or_create_by(name: item[0], machine_name: item[1])
      ImportTerms.new(file, vocabulary).run
    end
  end
end
