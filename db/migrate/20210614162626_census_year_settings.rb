class CensusYearSettings < ActiveRecord::Migration[6.0]
  def up
    [1900, 1910, 1920, 1930, 1940].each do |year|
      group = "#{year} US Census"
      Setting.add "enabled_private_#{year}", type: :boolean, value: '1', group: group, name: 'Enabled Private', hint: 'This census year is available to logged-in users for data entry.'
      Setting.add "enabled_public_#{year}", type: :boolean, value: '1', group: group, name: 'Enabled Public', hint: 'This census year is available to the public for search.'
      Setting.add "add_buildings_#{year}", type: :boolean, value: '1', group: group, name: 'Add Buildings', hint: 'Allows census taker to create a new building from address.'
    end
  end

  def down
    [1900, 1910, 1920, 1930, 1940].each do |year|
      Setting.where(group: "#{year} US Census").delete_all
    end
  end
end
