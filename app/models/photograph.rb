# == Schema Information
#
# Table name: photographs
#
#  id             :bigint           not null, primary key
#  created_by_id  :bigint
#  building_id    :bigint
#  description    :text
#  creator        :string
#  date_text      :string
#  date_start     :date
#  date_end       :date
#  location       :string
#  identifier     :string
#  notes          :text
#  latitude       :decimal(, )
#  longitude      :decimal(, )
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  reviewed_by_id :bigint
#  reviewed_at    :datetime
#  date_type      :integer          default("year")
#  caption        :text
#
# Indexes
#
#  index_photographs_on_building_id     (building_id)
#  index_photographs_on_created_by_id   (created_by_id)
#  index_photographs_on_reviewed_by_id  (reviewed_by_id)
#

# frozen_string_literal: true

class Photograph < ApplicationRecord
  include Media
  include MediaDateBehavior

  has_one_attached :file
  validates :file, attached: true, content_type: %w[image/jpg image/jpeg image/png]

  default_scope -> { preload(file_attachment: :blob) }

  def process
    # nothing to do here, but lets us keep media controller simple.
  end
end
