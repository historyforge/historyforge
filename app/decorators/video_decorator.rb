# frozen_string_literal: true

class VideoDecorator < ApplicationDecorator
  def title
    object.title || 'Untitled'
  end

  def creator
    object.creator || 'Creator unknown'
  end

  def date
    object.date_text
  end

  def subject
    object.subject || 'Not specified'
  end
end
