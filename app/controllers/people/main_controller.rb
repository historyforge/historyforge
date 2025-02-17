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
      people = Person.name_fuzzy_matches(params[:term])
                     .limit(10)
                     .preload(:names)
      data = people.map do |person|
        { id: person.id,
          years: person.years,
          birth_year: person.birth_year,
          death_year: person.death_year,
          name: person.name,
          see_names: person.names.map(&:name),
          sex: person.sex }
      end
      render json: data
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

    def edit
      @person = Person.find params[:id]
      authorize! :update, @person
    end

    def create
      @person = Person.new resource_params
      authorize! :create, @person
      if @person.save
        flash[:notice] = 'Person created.'
        redirect_to @person
      else
        flash[:error] = 'Person not saved.'
        render action: :new
      end
    end

    def update
      @person = Person.find params[:id]
      authorize! :update, @person
      if @person.update resource_params
        flash[:notice] = 'Person updated.'
        redirect_to @person
      else
        flash[:error] = 'Person not saved.'
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
        flash[:error] = 'Unable to delete person.'
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
                                     :death_year,
                                     :pob, :is_pob_estimated, :notes, :description,
                                     names_attributes: %i[_destroy id first_name last_name],
                                     locality_ids: []
    end
  end
end
