# frozen_string_literal: true

class PhotographDecorator < ApplicationDecorator
  def title
    object.title || 'Untitled'
  end

  def creator
    object.creator || 'Photographer unknown'
  end

  def date
    object.date_text || 'No date'
  end

  def subject
    object.subject || 'Not specified'
  end
end
