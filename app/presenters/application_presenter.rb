class ApplicationPresenter
  def initialize(model, user)
    @model = model
    @user = user
  end

  attr_reader :model, :user

  def field_for(field)
    return public_send(field) if respond_to?(field)
    return model.public_send(field) if model.respond_to?(field)
    '?'
  end

  def method_missing(method, *args)
    model.public_send(method, *args)
  end

  def respond_to_missing?(method_name, include_private = false)
    model.send :respond_to_missing?, method_name, include_private
  end

end
