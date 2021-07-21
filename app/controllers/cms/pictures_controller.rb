class Cms::PicturesController < ActionController::Base

  def show
    @picture = Cms::Picture.find params[:id]

    # from style, how wide should it be? as % of 1278px
    width = case params[:device]
      when 'tablet'  then 1024
      when 'phone'   then 740
      else 1278
    end

    if params[:style] != 'full'
      case params[:style]
      when 'half'
        width = (width.to_f * 0.50).ceil
      when 'third'
        width = (width.to_f * 0.33).ceil
      when 'quarter'
        width = (width.to_f * 0.25).ceil
      else
        width = (width.to_f * params[:style].to_f).ceil
      end
    end

    redirect_to @picture.file.variant(resize_to_fit: [width, width * 3])
  end

end
