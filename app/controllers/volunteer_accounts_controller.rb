# frozen_string_literal: true

class VolunteerAccountsController < ApplicationController
  before_action :check_administrator_role
  before_action :load_application

  def new
    return redirect_to(user_path(@application.user)) if @application.user

    @user = User.new(login: @application.name.truncate(40, omission: ''), email: @application.email)
    load_matches
  end

  def create
    attributes = params.require(:volunteer_account).permit(:user_id, :login, :user_group_id)
    result = ConnectVolunteerUser.new(@application, current_user).call(**attributes.to_h.symbolize_keys)
    if result.invited
      begin
        result.user.deliver_invitation
        invitation_sent = true
        flash[:notice] = "Volunteer connected. An invitation email has been sent to #{result.user.email}."
      rescue StandardError => error
        Rails.logger.error("Volunteer invitation delivery failed (#{error.class}).")
        flash[:error] = 'The user was created and connected, but the invitation could not be sent. Use Resend Invite to try again.'
      end
      @application.resolve_submission_flag!(current_user) if invitation_sent
    else
      @application.resolve_submission_flag!(current_user) unless result.already_linked
      flash[:notice] = 'Volunteer connected to the existing user. Account permissions are unchanged.'
    end
    redirect_to user_path(result.user), status: :see_other
  rescue ConnectVolunteerUser::Conflict, ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => error
    @user = error.is_a?(ActiveRecord::RecordInvalid) && error.record.is_a?(User) ? error.record : User.new(login: attributes[:login])
    @user.errors.add(:base, error.is_a?(ActiveRecord::RecordNotUnique) ? 'That account was just changed. Please review and try again.' : error.message)
    load_matches
    render_form_with_errors(:new)
  end

  private

  def load_application
    response.headers['Cache-Control'] = 'no-store'
    @application = VolunteerApplication.find(params[:volunteer_application_id])
  end

  def load_matches
    @matching_users = User.where('LOWER(email) = ?', @application.email).order(:login)
  end
end
