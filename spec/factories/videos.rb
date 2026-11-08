# == Schema Information
#
# Table name: videos
#
#  id                     :integer          not null, primary key
#  created_by_id          :integer          not null
#  reviewed_by_id         :integer
#  reviewed_at            :datetime
#  description            :text
#  notes                  :text
#  caption                :text
#  creator                :string
#  date_type              :integer
#  date_text              :string
#  date_start             :date
#  date_end               :date
#  location               :string
#  identifier             :string
#  latitude               :decimal(, )
#  longitude              :decimal(, )
#  duration               :integer
#  file_size              :integer
#  width                  :integer
#  height                 :integer
#  thumbnail_processed_at :datetime
#  processed_at           :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  remote_url             :string
#  searchable_text        :text
#  institution_id         :integer
#  collection_id          :integer
#  source_record_url      :string
#  credit                 :text
#  rights_statement       :text
#
# Indexes
#
#  index_videos_on_collection_id   (collection_id)
#  index_videos_on_created_by_id   (created_by_id)
#  index_videos_on_institution_id  (institution_id)
#  index_videos_on_reviewed_by_id  (reviewed_by_id)
#

FactoryBot.define do
  factory :video do
    created_by { nil }
    description { "MyText" }
    creator { "MyString" }
    date_text { "MyString" }
    date_start { "2024-05-25" }
    date_end { "2024-05-25" }
    location { "MyString" }
    identifier { "MyString" }
    notes { "MyText" }
    latitude { "9.99" }
    longitude { "9.99" }
    reviewed_by { nil }
    reviewed_at { "2024-05-25 17:18:43" }
    date_type { 1 }
    caption { "MyText" }
  end
end
