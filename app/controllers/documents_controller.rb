# frozen_string_literal: true

class DocumentsController < ApplicationController
  include Moveable
  include FastMemoize

  def index
    authorize! :read, Document
    if AppConfig[:document_category_page]
      if params[:document_category_id]
        @documents = collection
      else
        @categories = DocumentCategory
                        .order(:position)
                        .joins(:documents)
                        .group('document_categories.id')
                        .having('COUNT(documents.id) > 0')
                        .select('document_categories.*, COUNT(documents.id) AS documents_count')
        if Current.locality_id
          @categories = @categories
                          .joins('LEFT JOIN documents_localities ON documents_localities.document_id=documents.id')
                          .where('locality_id IS NULL OR locality_id=?', Current.locality_id)

        end
      end
    else
      @documents = collection.group_by(&:document_category_id)
      @categories = DocumentCategory.order(:position)
    end
  end

  def new
    @document = Document.new
  end

  def edit
    @document = Document.find params[:id]
    authorize! :update, @document
  end

  def create
    @document = Document.new resource_params
    authorize! :create, @document
    if @document.save
      flash[:notice] = 'The document has been saved.'
      redirect_to action: :index, document_category_id: @document.document_category_id
    else
      flash[:error] = 'This document failed to upload. Usually it means the file type is not allowed.'
      render :new
    end
  end

  def update
    @document = Document.find params[:id]
    authorize! :update, @document
    if @document.update resource_params
      flash[:notice] = 'Great job! The document has been updated.'
      redirect_to action: :index, document_category_id: @document.document_category_id
    else
      flash[:error] = 'Sorry Dave I can\'t do that right now.'
      render action: :edit
    end
  end

  def destroy
    @document = Document.find params[:id]
    authorize! :destroy, @document
    if @document.destroy
      flash[:notice] = 'Poof it\'s gone! Like it never existed...'
      redirect_to action: :index
    else
      flash[:error] = 'Sorry I was not able to delete that document.'
      redirect_to :back
    end
  end

  private

  def resource_params
    params.require(:document).permit :file,
                                     :name,
                                     :description,
                                     :document_category_id,
                                     :url,
                                     :available_to_public,
                                     locality_ids: []
  end

  def collection
    (parent&.documents || Document)
      .authorized_for(current_user)
      .includes(file_attachment: :blob)
      .order(:position)
      .for_locality_id(Current.locality_id)
  end
  memoize :collection

  def resource
    (parent&.documents || Document).authorized_for(current_user).find(params[:id])
  end
  memoize :resource

  def parent
    params[:document_category_id] ? DocumentCategory.find(params[:document_category_id]) : nil
  end
  memoize :parent
  helper_method :parent
end
