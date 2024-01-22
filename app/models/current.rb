# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :locality_id

  def locality
    return unless locality_id

    @locality ||= Locality.find(locality_id)
  end
end
