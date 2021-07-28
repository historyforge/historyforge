module People
  class MainController < ApplicationController
    # before_action :check_access

    def index
      load_people
      render_people
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
    end

    def create
      @person = Person.new resource_params
      authorize! :create, @person
      @person.created_by = current_user
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

    def new_resource_path
      new_person_path
    end

    helper_method :new_resource_path

    private

    def check_access
      permission_denied unless can_people?
    end

    def resource_class
      Person
    end
    helper_method :resource_class

    def resource_params
      params.require(:person).permit :first_name, :last_name, :middle_name,
                                     :sex, :race, :name_prefix, :name_suffix, :birth_year, :is_birth_year_estimated,
                                     :pob, :is_pob_estimated
    end

    def load_people
      authorize! :read, Person
      @search = PersonSearch.generate params: params, user: current_user
    end

    def render_people
      @translator = CensusGridTranslator.new(@search)
      if request.format.html?
        render action: :index
      else
        if params[:from]
          render plain: @translator.row_data, content_type: 'application/json'
        elsif request.format.csv?
          render_csv
        else
          @records = @search.results
          respond_with @records, each_serializer: PersonSerializer
        end
      end
    end

    def render_csv
      headers["X-Accel-Buffering"] = "no"
      headers["Cache-Control"] = "no-cache"
      headers["Content-Type"] = "text/csv; charset=utf-8"
      headers["Content-Disposition"] = %(attachment; filename="historyforge-person-search.csv")
      headers["Last-Modified"] = Time.zone.now.ctime.to_s
      self.response_body = Enumerator.new do |csv|
        headers = @search.columns.map { |field| Translator.label(Person, field) }
        csv << CSV.generate_line(headers)
        @search.results.each do |row|
          row_results = @search.columns.map { |field| row.field_for(field) }
          csv << CSV.generate_line(row_results)
        end
      end
    end
  end
end
