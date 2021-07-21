class PhotoCartsController < ApplicationController
  def fetch
    @photos = Photograph.where(id: params[:ids])
    render json: @photos.map { |photo| { id: photo.id,
                                             title: (photo.caption || photo.description)[0..40],
                                             photo: url_for(photo.file.variant(resize_to_fit: [300, 300])) } }
  end

  def export
    @photos = Photograph.where(id: params[:ids])
    respond_to do |format|
      format.csv do
        require 'csv'
        headers['Content-Disposition'] = "attachment; filename=\"nyh-extract.csv\""
        headers['Content-Type'] = "text/csv"
      end
      format.zip do
        require 'csv'
        require 'zip'

        csv = render_to_string formats: %i[csv]
        file = Tempfile.new
        Zip::File.open(file, Zip::File::CREATE) do |zipfile|
          zipfile.get_output_stream('Contents.csv') { |f| f.write csv }
          @photos.each do |photo|
            zipfile.get_output_stream(photo.file.filename) { |f| f.write photo.file.download }
          end
        end
        send_file file, type: 'application/zip', filename: 'NYHeritage Photo Export.zip'
      end
    end
  end

  def index
  end
end
