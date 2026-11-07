# frozen_string_literal: true

module Api
  module V1
    class PeopleController < ApplicationController
      skip_before_action :check_cms_for_page

      def show
        return permission_denied unless Setting.can_people_public?

        person = Person.find_by(id: params[:id])
        return render json: { error: 'not_found' }, status: :not_found unless person

        public_ability = Ability.new(nil)
        public_ability.authorize! :read, person
        public_years = CensusYears.visible_to_user(nil)
        readable = ->(record) { public_years.include?(record.year) && public_ability.can?(:read, record) }
        evidence = People::LoadCensusEvidence.call(person:, readable:)

        render json: PersonSerializer.new(person, **evidence.to_h, url_options: url_options.except(:_recall))
      end

      private

      def permission_denied
        render json: { error: 'forbidden' }, status: :forbidden
      end
    end
  end
end
