# == Schema Information
#
# Table name: search_params
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           not null
#  model      :string
#  params     :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_search_params_on_user_id  (user_id)
#

# frozen_string_literal: true

class SearchParam < ApplicationRecord
  belongs_to :user
end
