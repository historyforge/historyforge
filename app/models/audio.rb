# frozen_string_literal: true

class Audio < ApplicationRecord
  include Media
  include MediaDateBehavior
end
