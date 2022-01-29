# frozen_string_literal: true

class DocumentCategoriesController < ApplicationController
  include Moveable

  def index
    authorize! :read, DocumentCategory
    @document_categories = DocumentCategory.order(:position)
    @document_category = DocumentCategory.new
  end

  def new
    @document_category = DocumentCategory.new
  end

  def create
    @document_category = DocumentCategory.new resource_params
    authorize! :create, @document_category
    if @document_category.save
      flash[:document] = 'Good job creating the fcategory!'
      redirect_to action: :index
    else
      flash[:errors] = 'We had some problems doing that.'
      render :new
    end
  end

  def edit
    @document_category = DocumentCategory.find params[:id]
    authorize! :update, @document_category
  end

  def update
    @document_category = DocumentCategory.find params[:id]
    authorize! :update, @document_category
    if @document_category.update resource_params
      flash[:notice] = 'Great job! The document category has been updated.'
      redirect_to action: :index
    else
      flash[:errors] = 'Sorry Dave I can\'t do that right now.'
      render action: :edit
    end
  end

  def destroy
    @document_category = DocumentCategory.find params[:id]
    authorize! :destroy, @document_category
    if @document_category.destroy
      flash[:notice] = 'Poof it\'s gone! Like it never existed...'
      redirect_to action: :index
    else
      flash[:errors] = 'Sorry I was not able to delete that document category.'
      redirect_to :back
    end
  end

  private

  def resource_params
    params.require(:document_category).permit :name, :description
  end

  def resource
    @document_category ||= DocumentCategory.find(params[:id])
  end
end
