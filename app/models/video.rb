# frozen_string_literal: true

class Video < ApplicationRecord
  include Media
  include MediaDateBehavior
end
