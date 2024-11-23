# frozen_string_literal: true

class Cms::PagesController < ApplicationController

  layout 'application', except: [:show]
  before_action :load_page, only: %i[show edit update destroy]
  before_action :check_page_access, only: [:show]

  def index
    authorize! :manage, Cms::Page
    @search = Cms::Page.ransack(params[:q])
    @pages = @search.result.page(params[:page] || 1)
  end

  def show
    render layout: 'cms'
  end

  def new
    @page = Cms::Page.generate
    authorize! :create, @page
    return unless params[:page]

    page_params = params[:page]
    @page.url_path   = page_params[:url_path].sub(/\A\//, '')
    @page.controller = page_params[:controller].to_s
    @page.action     = page_params[:action].to_s
  end

  def edit
    authorize! :update, @page
  end

  def create
    @page = Cms::Page.new resource_params
    authorize! :create, @page
    if @page.save
      flash[:notice] = "Successfully created page \"#{@page.title}\"!"
      redirect_to params[:next] == 'edit' ? edit_cms_page_path(@page) : @page
    else
      flash[:errors] = 'The page was not created because of errors on the form.'
      render action: :new
    end
  end

  def update
    authorize! :update, @page
    if @page.update resource_params
      flash[:notice] = "Successfully updated page \"#{@page.title}\"!"
      redirect_to params[:next] == 'edit' ? edit_cms_page_path(@page) : @page
    else
      flash[:errors] = 'The page was not updated because of errors on the form.'
      render action: :edit
    end
  end

  def destroy
    authorize! :destroy, @page
    if @page.destroy
      flash[:notice] = "Successfully deleted page \"#{@page.title}\"!"
      redirect_to action: :index
    else
      flash[:errors] = 'Sorry we could not delete the page.'
      redirect_to @page
    end
  end

  private

  def resource_params
    params.require(:cms_page).permit!
  end

  def load_page
    if params[:id]
      @page = Cms::Page.find params[:id]
    elsif params[:path]
      url_path = "/#{params[:path]}"
      @page = Cms::Page.where(url_path: url_path).includes(:widgets).first
    end
    page_not_found if @page.blank?
  end

  def check_page_access
    check_access_via_callback

    if @page.controller.present? && @page.action.present?
      page_not_found unless can?(:update, @page)
    elsif !@page.published?
      if can?(:update, @page)
        flash[:notice] = 'This page is not published. You can see it only because you can edit pages.'
      else
        page_not_found
      end
    end
  end

  def check_access_via_callback
    access_callback = @page.access_callback
    return unless access_callback
    return unless respond_to?(access_callback)

    raise CanCan::AccessDenied unless public_send(access_callback)
  end
end
