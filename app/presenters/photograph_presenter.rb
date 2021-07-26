# frozen_string_literal: true

class PhotographPresenter < ApplicationPresenter
  def title
    model.title || 'Untitled'
  end

  def creator
    model.creator || "Photographer unknown"
  end

  def date
    model.date_text || 'No date'
  end

  def subject
    model.subject || 'Not specified'
  end
end
