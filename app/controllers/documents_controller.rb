class DocumentsController < ApplicationController
  include Moveable

  def index
    authorize! :read, Document
    @documents = collection.group_by(&:document_category_id)
    @categories = DocumentCategory.all
    @document = Document.new
  end

  def new
    @document = Document.new
  end

  def create
    @document = Document.new resource_params
    authorize! :create, @document
    if @document.save
      flash[:notice] = 'Good job uploading the document!'
      redirect_to action: :index
    else
      flash[:errors] = 'This document failed to upload. Usually it means the file type is not allowed.'
      render :new
    end
  end

  def edit
    @document = Document.find params[:id]
    authorize! :update, @document
  end

  def update
    @document = Document.find params[:id]
    authorize! :update, @document
    if @document.update resource_params
      flash[:notice] = 'Great job! The document has been updated.'
      redirect_to action: :index
    else
      flash[:errors] = 'Sorry Dave I can\'t do that right now.'
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
      flash[:errors] = 'Sorry I was not able to delete that document.'
      redirect_to :back
    end
  end

  private

  def resource_params
    params.require(:document).permit :file, :name, :description, :document_category_id, :url
  end

  def collection
    @documents ||= parent.order(:position)
  end

  def resource
    @document ||= parent.find(params[:id])
  end

  def parent
    @parent ||= params[:document_category_id] ? DocumentCategory.find(params[:document_category_id]).documents : Document
  end
end