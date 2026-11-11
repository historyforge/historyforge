# frozen_string_literal: true

module Api
  module V1
    class PeopleController < ActionController::API
      include CensusAccess
      include LoadSettings

      impersonates :user

      RATE_LIMIT_WINDOW = 1.minute
      requests_per_minute = Integer(ENV.fetch('PERSON_API_REQUESTS_PER_MINUTE', '0'), 10)
      if requests_per_minute.positive?
        rate_limit to: requests_per_minute, within: RATE_LIMIT_WINDOW, only: :show,
                   store: ActiveSupport::Cache::MemoryStore.new, with: :rate_limit_exceeded
      end

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

      def rate_limit_exceeded
        no_store
        response.set_header('Retry-After', RATE_LIMIT_WINDOW.to_i.to_s)
        render json: { error: 'rate_limit_exceeded' }, status: :too_many_requests
      end

      def permission_denied
        render json: { error: 'forbidden' }, status: :forbidden
      end
    end
  end
end
