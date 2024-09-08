# frozen_string_literal: true

# == Schema Information
#
# Table name: videos
#
#  id                     :bigint           not null, primary key
#  created_by_id          :bigint           not null
#  reviewed_by_id         :bigint
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
#
# Indexes
#
#  index_videos_on_created_by_id   (created_by_id)
#  index_videos_on_reviewed_by_id  (reviewed_by_id)
#
class Video < ApplicationRecord
  include Media
  include MediaDateBehavior
end
