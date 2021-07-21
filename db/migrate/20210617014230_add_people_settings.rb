class AddPeopleSettings < ActiveRecord::Migration[6.0]
  def change
    Setting.add 'people_private',
                type: :boolean,
                value: '1',
                group: 'All People',
                name: 'Enabled Private',
                hint: 'Logged-in users can access the People pages. People records connect census records across multiple censuses.'
    Setting.add 'people_public',
                type: :boolean,
                value: '1',
                group: 'All People',
                name: 'Enabled Public',
                hint: 'The people pages are available to the public for search.'
  end
end
