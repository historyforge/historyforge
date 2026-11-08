# == Schema Information
#
# Table name: audios
#
#  id                :integer          not null, primary key
#  created_by_id     :integer          not null
#  reviewed_by_id    :integer
#  reviewed_at       :datetime
#  description       :text
#  notes             :text
#  caption           :text
#  creator           :string
#  date_type         :integer
#  date_text         :string
#  date_start        :date
#  date_end          :date
#  location          :string
#  identifier        :string
#  latitude          :decimal(, )
#  longitude         :decimal(, )
#  duration          :integer
#  file_size         :integer
#  processed_at      :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  remote_url        :string
#  searchable_text   :text
#  institution_id    :integer
#  collection_id     :integer
#  source_record_url :string
#  credit            :text
#  rights_statement  :text
#
# Indexes
#
#  index_audios_on_collection_id   (collection_id)
#  index_audios_on_created_by_id   (created_by_id)
#  index_audios_on_institution_id  (institution_id)
#  index_audios_on_reviewed_by_id  (reviewed_by_id)
#

require 'rails_helper'

RSpec.describe Audio, type: :model do
  it_behaves_like 'searchable reviewed media'
end
