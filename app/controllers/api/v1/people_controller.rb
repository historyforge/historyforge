# frozen_string_literal: true

module Api
  module V1
    class PeopleController < ActionController::API
      include CensusAccess
      include LoadSettings
      include PublicApiRateLimit

      impersonates :user

      rescue_from CanCan::AccessDenied, with: :permission_denied

      def show
        return permission_denied unless Setting.can_people_public?

        person = Person.find_by(id: params[:id])
        return render json: { error: 'not_found' }, status: :not_found unless person

        authorize! :read, person
        evidence = People::LoadCensusEvidence.call(person:, readable: method(:census_record_readable?))

        no_store if user_signed_in?
        render json: PersonSerializer.new(person, **evidence.to_h, url_options: url_options.except(:_recall))
      end

      private

      def permission_denied
        render json: { error: 'forbidden' }, status: :forbidden
      end
    end
  end
end
