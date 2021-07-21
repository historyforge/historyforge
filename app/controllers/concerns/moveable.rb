module Moveable
  def move_to_top
    authorize! :update, resource
    resource.move_to_top
    redirect_back fallback_location: { action: :index }
  end

  def move_up
    authorize! :update, resource
    resource.move_higher
    redirect_back fallback_location: { action: :index }
  end

  def move_down
    authorize! :update, resource
    resource.move_lower
    redirect_back fallback_location: { action: :index }
  end

  def move_to_bottom
    authorize! :update, resource
    resource.move_to_bottom
    redirect_back fallback_location: { action: :index }
  end
end