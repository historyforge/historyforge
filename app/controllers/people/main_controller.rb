# frozen_string_literal: true

module People
  class MainController < ApplicationController
    include AdvancedRestoreSearch
    include RenderCsv

    def index
      authorize! :read, Person
      @search = PersonSearch.generate params: search_params, user: current_user
      @translator = PersonGridTranslator.new(@search)
      respond_to do |format|
        format.html
        format.json { render json: @translator.row_data }
        format.csv { render_csv('people', Person) }
      end
    end

    def autocomplete
      @people = Person.fuzzy_name_search(params[:term]).limit(5).by_name
      render json: @people.map { |person|
        {
          id: person.id,
          name: person.name
        }
      }
    end

    def show
      @person = Person.find params[:id]
      authorize! :read, @person
    end

    def new
      authorize! :create, Person
      @person = Person.new
      @person.names.build(is_primary: true)
    end

    def create
      @person = Person.new resource_params
      authorize! :create, @person
      if @person.save
        flash[:notice] = 'Person created.'
        redirect_to @person
      else
        flash[:errors] = 'Person not saved.'
        render action: :new
      end
    end

    def edit
      @person = Person.find params[:id]
      authorize! :update, @person
    end

    def update
      @person = Person.find params[:id]
      authorize! :update, @person
      if @person.update resource_params
        flash[:notice] = 'Person updated.'
        redirect_to @person
      else
        flash[:errors] = 'Person not saved.'
        render action: :edit
      end
    end

    def destroy
      @person = Person.find params[:id]
      authorize! :destroy, @person
      if @person.destroy
        flash[:notice] = 'Person deleted.'
        redirect_to action: :index
      else
        flash[:errors] = 'Unable to delete person.'
        redirect_to :back
      end
    end

    private

    def search_params
      params.permit!.to_h
    end

    def resource_class
      Person
    end
    helper_method :resource_class

    def resource_params
      params.require(:person).permit :first_name, :last_name, :middle_name,
                                     :sex, :race, :name_prefix, :name_suffix, :birth_year, :is_birth_year_estimated,
                                     :pob, :is_pob_estimated, :notes, :description,
                                     names_attributes: %i[_destroy id is_primary name_prefix first_name middle_name last_name name_suffix]
    end
  end
end
