class Video < ApplicationRecord
  belongs_to :created_by
  belongs_to :reviewed_by
end
