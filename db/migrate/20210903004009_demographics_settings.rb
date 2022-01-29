# frozen_string_literal: true

class DemographicsSettings < ActiveRecord::Migration[6.0]
  def change
    CensusYears.each do |year|
      group = "#{year} US Census"
      Setting.add "demographics_private_#{year}",
                  type: :boolean,
                  value: '0',
                  group: group,
                  name: 'Demographics Private',
                  hint: 'The demographics page is available to logged-in users for this census year.'

      Setting.add "demographics_public_#{year}",
                  type: :boolean,
                  value: '0',
                  group: group,
                  name: 'Demographics Public',
                  hint: 'The demographics page is available to the public for this census year.'
    end
  end
end
