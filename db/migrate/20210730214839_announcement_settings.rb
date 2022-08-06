# frozen_string_literal: true

class AnnouncementSettings < ActiveRecord::Migration[6.0]
  def change
    group = 'Announcement Banner'
    Setting.add 'announcement_show', type: :boolean, value: '0', group: group, name: 'Show announcement?', hint: 'Should we show the announcement banner on the home page?'
    Setting.add 'announcement_text', type: :string, value: nil, group: group, name: 'Announcement Text', hint: 'The text of the announcement.'
    Setting.add 'announcement_url', type: :string, value: nil, group: group, name: 'Announcement URL', hint: 'Go somewhere when you click on the announcement? Enter a URL starting with https://.'
  end
end
