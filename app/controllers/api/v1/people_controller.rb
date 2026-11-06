# frozen_string_literal: true

module Api
  module V1
    class PeopleController < ApplicationController
      skip_before_action :check_cms_for_page

      def show
        return permission_denied unless Setting.can_people_public?

        person = Person.find_by(id: params[:id])
        return render json: { error: 'not_found' }, status: :not_found unless person

        authorize! :read, person
        render json: PersonSerializer.new(person, routes: self)
      end

      private

      def permission_denied
        render json: { error: 'forbidden' }, status: :forbidden
      end
    end
  end
end
