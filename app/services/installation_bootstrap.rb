# frozen_string_literal: true

class InstallationBootstrap
  def initialize(input: $stdin, output: $stdout)
    @input = input
    @output = output
  end

  def run
    tables = ApplicationRecord.connection.tables - %w[schema_migrations ar_internal_metadata]
    unless tables.empty?
      raise "Fresh installation requires an empty database; existing tables were found. " \
            "No schema was loaded. To finish an interrupted installation, run db:seed, " \
            "hf:load_occupation_codes, and hf:create_admin as needed."
    end

    Rake::Task['db:schema:load'].invoke
    Rake::Task['db:seed'].invoke
    LoadOccupationCodes.new.run
    CreateAdministrator.new(input: @input, output: @output).run
    @output.puts 'Initialization complete. Deploy the app, then sign in to configure your collection.'
  end
end
