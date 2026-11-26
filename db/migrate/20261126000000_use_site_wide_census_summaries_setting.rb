# frozen_string_literal: true

class UseSiteWideCensusSummariesSetting < ActiveRecord::Migration[8.1]
  def up
    Setting.add_census_summaries_setting
    legacy_keys = CensusYears::YEARS.flat_map { |year| ["demographics_public_#{year}", "demographics_private_#{year}"] }
    Setting.where(key: legacy_keys).delete_all
    Setting.expire_cache
  end

  def down
    Setting.where(key: 'census_summaries_enabled').delete_all
    Setting.expire_cache
  end
end
