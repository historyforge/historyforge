# frozen_string_literal: true

class ApplicationController < ActionController::Base
  impersonates :user
  protect_from_forgery with: :exception

  around_action :load_settings
  around_action :set_current_attributes
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_paper_trail_whodunnit

  if Rails.env.production?
    rescue_from ActiveRecord::RecordNotFound,
                ActionController::RoutingError,
                Mime::Type::InvalidMimeType,
                ActionController::MethodNotAllowed, with: :page_not_found
  end
  before_action :check_cms_for_page
  layout :cms_choose_layout

  rescue_from CanCan::AccessDenied, with: :permission_denied

  def can_census?(year)
    Setting.can_view_public?(year) || (user_signed_in? && Setting.can_view_private?(year))
  end

  def can_demographics?(year)
    Setting.can_view_public_demographics?(year) || (user_signed_in? && Setting.can_view_private_demographics?(year))
  end

  def can_people?
    Setting.can_people_public? || (user_signed_in? && Setting.can_people_private?)
  end
  helper_method :can_census?, :can_demographics?, :can_people?

  def check_administrator_role
    check_role('administrator')
  end

  def check_cms_for_page
    Rails.logger.info "Looking for #{params[:controller]}##{params[:action]} template."
    a = params[:action]
    a = 'new' if a == 'create'
    a = 'edit' if a == 'update'
    @page = Cms::Page.find_by(controller: self.class.name, action: a)
  end

  def cms_choose_layout
    @page.present? ? 'cms' : 'application'
  end

  def page_not_found
    @page = Cms::Page.find_or_initialize_by(controller: 'pages', action: '404')

    # Ensure that we have a custom 404 page
    if @page.new_record?
      @page.title = '404 Page Not Found'
      @page.url_path = '/404_error'
      @page.template = "The page was not found :(\r\n\r\n{{content}}"
      @page.save!
    end

    # This weirdness is needed so that it doesn't render the xml template for html
    respond_to do |format|
      format.html { render('cms/pages/page_404', status: 404, layout: 'cms') }
      format.json { render('cms/pages/page_404', status: 404, layout: 'cms') }
      format.xml  { render('cms/pages/page_404', status: 404, layout: 'cms') }
    end

    true
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit :sign_up, keys: %i[login description email password password_confirmation]
    devise_parameter_sanitizer.permit :account_update, keys: %i[login description email password password_confirmation current_password]
    devise_parameter_sanitizer.permit(:accept_invitation, keys: %i[login password password_confirmation])
    devise_parameter_sanitizer.permit(:invite, keys: %i[login email])
  end

  def check_role(role)
    permission_denied unless user_signed_in? && current_user.has_role?(role)
  end

  def permission_denied
    flash[:error] = 'Sorry you do not have permission to do that.'
    redirect_to root_path
  end

  private

  def after_invite_path_for(_user)
    users_path
  end

  def load_settings
    Setting.load
    yield
    Setting.unload
  end

  def set_current_attributes
    if params[:locality_slug]
      Current.locality = Locality.find_by(slug: params[:locality_slug])
      Current.locality_id = Current.locality&.id
      session[:locality] = Current.locality_id
    elsif session[:locality]
      Current.locality_id = session[:locality]
      Current.locality = Locality.find Current.locality_id
    end
    yield
    Current.reset
  end
end
