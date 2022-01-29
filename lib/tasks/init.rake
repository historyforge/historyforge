# frozen_string_literal: true

namespace :init do
  task do_it: %i[build terms fixtures new_admin_user]

  task new_admin_user: :environment do
    user = User.new
    user.add_role Role.find_by(name: 'Administrator')
    STDOUT.puts "Generating admin user. \n"
    STDOUT.puts "\nUser name: "
    user.login = STDIN.gets.chomp
    STDOUT.puts "\nEmail: "
    user.email = STDIN.gets.chomp
    chars = '!@#$%^&*(){}[]'.split + '!@#$%^&*(){}[]'.split + ('0'..'9').to_a + ('A'..'Z').to_a + ('a'..'z').to_a
    pwd = chars.sort_by { rand }.join[0...16]
    user.password = pwd
    user.password_confirmation = pwd
    user.confirmed_at = Time.now
    if user.save
      STDOUT.puts "A new user has been created with the email #{user.email}. The password is: \n#{pwd}"
    else
      STDOUT.puts 'Unable to create the new user. Usually this means a user by that email already exists.'
    end
  end

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

task init: 'init:do_it'
