# frozen_string_literal: true

class Cms::PicturesController < ActionController::Base

  def show
    @picture = Cms::Picture.find params[:id]
    redirect_to @picture.file.variant(resize_to_fit: ResizeToFit.run!(style: params[:style], device: params[:device]))
  end

end
