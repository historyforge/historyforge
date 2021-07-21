class PhotographPresenter < Struct.new(:model, :user)

  def initialize(model, user)
    self.model, self.user = model, user
  end

  def title
    model.title || 'Untitled'
  end

  def creator
    model.creator || "Photographer unknown"
  end

  def physical_format
    model.physical_format&.name || 'Unspecified format'
  end

  def date
    model.date_text || 'No date'
  end

  def subject
    model.subject || 'Not specified'
  end

  def physical_type
    model.physical_type&.name || 'Not specified'
  end

  def rights_name
    model.rights_statement&.name || 'Not specified'
  end

  def rights_description
    model.rights_statement&.description
  end

  def method_missing(method, *args)
    model.public_send(method, *args)
  end
end