class PhotoSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :caption, :url

  def url
    object.photo.url
  end

end
