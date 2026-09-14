# frozen_string_literal: true

require 'yaml'

class LoadOccupationCodes
  def run
    # These are reference records, not test fixtures: never disable constraints
    # or replace existing records (including locally edited descriptions).
    Occupation1930Code.transaction do
      YAML.safe_load_file(Rails.root.join('db/fixtures/occupation1930_codes.yml')).each_value do |attributes|
        Occupation1930Code.find_or_create_by!(code: attributes.fetch('code')) do |record|
          record.name = attributes.fetch('name')
        end
      end
    end
  end
end
