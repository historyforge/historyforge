# == Schema Information
#
# Table name: narratives
#
#  id             :bigint           not null, primary key
#  created_by_id  :bigint           not null
#  reviewed_by_id :bigint
#  reviewed_at    :datetime
#  weight         :integer          default(0)
#  source         :string
#  notes          :text
#  date_type      :integer
#  date_text      :string
#  date_start     :date
#  date_end       :date
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_narratives_on_created_by_id   (created_by_id)
#  index_narratives_on_reviewed_by_id  (reviewed_by_id)
#
require 'rails_helper'

RSpec.describe Narrative, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
