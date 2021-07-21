module RestoreSearch
  extend ActiveSupport::Concern

  included do
    before_action :restore_search, only: :index, unless: :json_request?
  end

  private

  def json_request?
    request.format.json?
  end

  def restore_search
    q_key = "q_#{controller_name}"
    p_key = "p_#{controller_name}"
    if params[:reset]
      session.delete q_key
      session.delete p_key
      redirect_to action: params[:action]
    elsif params[:q]
      if session.key?(q_key) and session[q_key] != params[:q]
        session[p_key] = 1
      else
        session[p_key] = params[:page] || 1
      end
      session[q_key] = params[:q]
    elsif session.key?(q_key)
      redirect_to action: params[:action], q: session[q_key], page: (session[p_key] || 1)
    end
  end
end
