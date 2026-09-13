# frozen_string_literal: true

namespace :hf do
  desc 'Prepare an empty database: schema, seeds, occupation codes, and first administrator'
  task bootstrap: :environment do
    InstallationBootstrap.new.run
  end

  desc 'Insert missing 1930 occupation codes without replacing existing records'
  task load_occupation_codes: :environment do
    LoadOccupationCodes.new.run
  end

  desc 'Create an administrator interactively'
  task create_admin: :environment do
    CreateAdministrator.new.run
  end
end
