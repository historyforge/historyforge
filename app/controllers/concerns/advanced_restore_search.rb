module AdvancedRestoreSearch
  extend ActiveSupport::Concern

  included do
    rescue_from PG::UndefinedFunction, with: :reset_search
    before_action :restore_search, only: %i[index], unless: :json_request?
  end

  private

  def restore_search
    restore_for_current_user || restore_for_guest_user
  end

  # Not restoring filters for json request because these will already have the filters
  # made available to them from the HTML page.
  def json_request?
    request.format.json?
  end

  def reset_search
    if current_user
      search = current_user.search_params.find_or_initialize_by(model: controller_name)
      search&.destroy
    else
      session.delete :search
    end
    redirect_to action: params[:action]
  end

  # For logged-in user we save filters for each search page to the database so as to
  # avoid cookie overflow errors.
  def restore_for_current_user
    return unless current_user

    search = current_user.search_params.find_or_initialize_by(model: controller_name)
    if resetting_search?
      search&.destroy
      redirect_to action: params[:action]
    elsif actively_searching?
      search.params = {
        s: params[:s].dup,
        fs: params[:fs].dup,
        f: params[:f].dup
      }
      search.save
    elsif search.persisted?
      redirect_to search.params.merge(action: params[:action])
    end

    true
  end

  # For guest users we save the filters to the cookie-based session. To avoid a cookie
  # overflow (ew!) we just store the filters for the last thing they were searching. So
  # if they search buildings then they search 1900 census records, the 1900 filters will
  # replace the building filters.
  def restore_for_guest_user
    if resetting_search?
      session.delete :search
    elsif actively_searching?
      session[:search] = {
        model: controller_name,
        params: {
          s: params[:s].dup,
          fs: params[:fs].dup,
          f: params[:f].dup
        }
      }
    elsif session[:search] && session[:search]['model'] == controller_name
      redirect_to session[:search]['params'].merge(action: params[:action])
    end
  end

  def resetting_search?
    params[:reset]
  end

  def actively_searching?
    params[:s] || params[:f] || params[:fs]
  end
end
