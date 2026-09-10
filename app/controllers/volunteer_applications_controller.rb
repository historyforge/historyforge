# frozen_string_literal: true

class VolunteerApplicationsController < ApplicationController
  include RecaptchaHandlers

  before_action :check_administrator_role, only: %i[index show update]
  before_action :load_choices, only: %i[new create]
  before_action :private_response

  def new
    @volunteer_application = VolunteerApplication.new
  end

  def create
    @volunteer_application = VolunteerApplication.new(application_params)
    valid_choices = assign_interests
    captcha_valid = !using_recaptcha? || verify_recaptcha(action: 'volunteer_application', minimum_score: 0.5,
                                                         secret_key: AppConfig[:recaptcha_secret_key])
    if valid_choices && captcha_valid && @volunteer_application.save
      redirect_to thank_you_volunteer_applications_path, status: :see_other
    else
      @volunteer_application.errors.add(:base, 'Please complete the spam verification and try again.') unless captcha_valid
      render_form_with_errors(:new)
    end
  end

  def thank_you; end

  def index
    @volunteer_applications = VolunteerApplication.order(created_at: :desc).page(params[:page]).per(50)
  end

  def show
    @volunteer_application = VolunteerApplication.find(params[:id])
  end

  def update
    @volunteer_application = VolunteerApplication.find(params[:id])
    if @volunteer_application.update(params.require(:volunteer_application).permit(:status, :staff_notes))
      redirect_to @volunteer_application, notice: 'Application updated.', status: :see_other
    else
      render_form_with_errors(:show)
    end
  end

  private

  def private_response
    response.headers['Cache-Control'] = 'no-store'
  end

  def load_choices
    @localities = Locality.pluck(:name)
    @opportunities = VolunteerApplication::OPPORTUNITIES.map { |code, label| [label, code] }
  end

  def application_params
    params.require(:volunteer_application).permit(:name, :email, :how_heard, :experience, :experience_details,
                                                 :other_interest, :comments)
  end

  def assign_interests
    selections = params.require(:volunteer_application).permit(locality_names: [], opportunity_interests: [])
    @volunteer_application.assign_attributes(selections)
    return true if (@volunteer_application.locality_names - @localities).empty? &&
                   (@volunteer_application.opportunity_interests - VolunteerApplication::OPPORTUNITIES.keys).empty?

    @volunteer_application.errors.add(:base, 'An interest is no longer available. Please review your selections.')
    false
  end
end
