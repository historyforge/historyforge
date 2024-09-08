# == Schema Information
#
# Table name: audios
#
#  id             :bigint           not null, primary key
#  created_by_id  :bigint           not null
#  reviewed_by_id :bigint
#  reviewed_at    :datetime
#  description    :text
#  notes          :text
#  caption        :text
#  creator        :string
#  date_type      :integer
#  date_text      :string
#  date_start     :date
#  date_end       :date
#  location       :string
#  identifier     :string
#  latitude       :decimal(, )
#  longitude      :decimal(, )
#  duration       :integer
#  file_size      :integer
#  processed_at   :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  remote_url     :string
#
# Indexes
#
#  index_audios_on_created_by_id   (created_by_id)
#  index_audios_on_reviewed_by_id  (reviewed_by_id)
#
require 'rails_helper'

RSpec.describe Audio, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
