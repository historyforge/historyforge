# frozen_string_literal: true

require 'csv'
require 'yaml'
require 'securerandom'

class InstallationBootstrap
  def initialize(input: $stdin, output: $stdout)
    @input = input
    @output = output
  end

  def run
    ApplicationRecord.transaction do
      {
        'language' => 'Language Spoken',
        'pob' => 'Place of Birth',
        'relation_to_head' => 'Relation to Head'
      }.each do |machine_name, name|
        vocabulary = Vocabulary.find_or_create_by!(machine_name:) { |record| record.name = name }
        CSV.foreach(Rails.root.join('db', "#{name}.csv")) do |row|
          vocabulary.terms.find_or_create_by!(name: row.first) if row.first.present?
        end
      end

      YAML.safe_load_file(Rails.root.join('db/fixtures/occupation1930_codes.yml')).each_value do |attributes|
        Occupation1930Code.find_or_create_by!(code: attributes.fetch('code')) do |record|
          record.name = attributes.fetch('name')
        end
      end
    end

    if User.includes(:group).any? { |user| user.role?('Administrator') }
      @output.puts 'An administrator already exists; keeping existing accounts and passwords.'
    else
      create_admin
    end
    @output.puts 'Initialization complete. Sign in to configure your locality, census years, and organization settings.'
  end

  def create_admin
    user = User.new(login: prompt('User name'), email: prompt('Email'))
    user.role_ids = [Role.find_by(name: 'Administrator').id]
    password = SecureRandom.base64(24)
    user.password = user.password_confirmation = password
    user.confirmed_at = Time.current
    user.save!
    @output.puts "Administrator created: #{user.email}\nPassword: #{password}\nSave this password securely."
  end

  private

  def prompt(label)
    @output.puts "#{label}:"
    value = @input.gets&.strip
    raise ArgumentError, "#{label} is required. Run this command in an interactive terminal." if value.blank?

    value
  end
end
