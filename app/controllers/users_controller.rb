# frozen_string_literal: true

class UsersController < ApplicationController
  include RestoreSearch

  layout 'application'

  before_action :authenticate_user!,
                only: %i[show edit update]

  before_action :check_administrator_role,
                only: %i[index new create destroy enable disable disable_and_reset resend_invitation]

  rescue_from ActiveRecord::RecordNotFound, with: :bad_record

  def index
    @q = User.includes(:group).ransack(ransack_params)
    @users = @q.result.page(params[:page]).order('email asc')
  end

  def show
    @user = User.find(params[:id]) || current_user
    return unless @user.unconfirmed_email && @user.unconfirmed_email != @user.email

    flash[:errors] = "You changed your email from #{@user.email} to #{@user.unconfirmed_email}. The change won't take effect until you click on the link in the email we sent you."
  end

  def new
    @user = User.new
    authorize! :create, @user
  end

  def edit
    @html_title = 'Edit User Settings'
    @user = params[:id] ? User.find(params[:id]) : current_user
    authorize! :update, @user
    return unless @user.unconfirmed_email && @user.unconfirmed_email != @user.email

    flash.now[:errors] = "You changed your email from #{@user.email} to #{@user.unconfirmed_email}.The change won't take effect until you click on the link in the email we sent you."
  end

  def create
    authorize! :create, User
    @user = User.invite!(user_params, current_user)
    if @user.save
      flash[:notice] = "An invitation email has been sent to #{@user.email}."
      redirect_to user_path(@user)
    else
      flash[:errors] = 'Could not invite user.'
      render action: :new
    end
  end

  def update
    @user = current_user
    @user = params[:id] ? User.find(params[:id]) : current_user
    authorize! :update, @user
    if @user.update(user_params)
      flash[:notice] = 'User updated'
      redirect_to user_path(@user)
    else
      flash[:errors] = "Unable to save the user record. #{@user.errors.full_messages.join('. ')}"
      @html_title = 'Edit User Settings'
      render action: 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user.has_role?('administrator')
      flash[:error] = 'Admin users cannot be deleted'
    else
      if @user.destroy
        flash[:notice] = 'User successfully deleted'
      else
        flash[:error] = 'User could not be deleted'
      end
    end
    redirect_to action: 'index'
  rescue PG::ForeignKeyViolation
    flash[:error] = 'Cannot delete error because they have added records, such as building and census records, that we would prefer not to delete or orphan. We suggest you disable the user instead.'
    redirect_to action: 'index'
  end

  def disable_and_reset
    @user = User.find(params[:id])
    if @user.provider?
      flash[:error] = 'Sorry, users from other providers are not able to be reset'
      return redirect_to action: 'show'
    end
    if @user.has_role?('administrator')
      flash[:error] = 'Admins cannot be disabled and reset, sorry'
    else
      generated_password = Devise.friendly_token.first(8)
      @user.password = generated_password
      @user.password_confirmation = generated_password

      if @user.save
        UserMailer.disabled_change_password(@user).deliver_now
        @user.send_reset_password_instructions
        flash[:notice] = 'User changed and an email sent with password reset link'
      else
        flash[:error] = 'Sorry, there was a problem changing this user'
      end
    end

    redirect_to action: 'show'
  end

  def disable
    @user = User.find(params[:id])
    if @user.update(enabled: false)
      flash[:notice] = 'User disabled'
    else
      flash[:error] = 'There was a problem disabling this user.'
    end
    redirect_to action: 'index'
  end

  def enable
    @user = User.find(params[:id])
    if @user.update(enabled: true)
      flash[:notice] = 'User enabled'
    else
      flash[:error] = 'There was a problem enabling this user.'
    end
    redirect_to action: 'index'
  end

  def bad_record
    respond_to do | format |
      format.html do
        flash[:notice] = 'User not found'
        redirect_to root_path
      end
      format.json { render json: {stat: 'not found', items: []}.to_json, status: 404 }
    end
  end

  def mask
    @user = User.find(params[:id])
    authorize! :mask, @user
    impersonate_user(@user)
    flash[:notice] = "You are now impersonating #{@user.name}. Log out to return control."
    redirect_to root_path
  end

  def resend_invitation
    user = User.find params[:id]
    user.deliver_invitation
    flash[:notice] = 'Resent the invitation!'
    redirect_to action: :edit
  end

  private

  def user_params
    params.require(:user).permit(:login, :email, :password, :password_confirmation, :user_group_id)
  end

  def ransack_params
    return {} if params[:q].blank?

    params.require(:q).permit!
  end
end
