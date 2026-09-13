# frozen_string_literal: true

namespace :hf do
  desc 'Initialize a site with default settings, reference data, and its first administrator'
  task bootstrap: ['db:seed'] do
    InstallationBootstrap.new.run
  end

  desc 'Create an additional administrator interactively'
  task create_admin: :environment do
    InstallationBootstrap.new.create_admin
  end
end
