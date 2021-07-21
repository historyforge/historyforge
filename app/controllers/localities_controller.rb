class LocalitiesController < ApplicationController
  before_action :check_administrator_role

  def index
    @localities = Locality.all
    ActiveRecord::Precounter.new(@localities).precount(:census1900_records)
    ActiveRecord::Precounter.new(@localities).precount(:census1910_records)
    ActiveRecord::Precounter.new(@localities).precount(:census1920_records)
    ActiveRecord::Precounter.new(@localities).precount(:census1930_records)
    ActiveRecord::Precounter.new(@localities).precount(:census1940_records)
  end

  def new
    @locality = Locality.new
  end

  def create
    @locality = Locality.new resource_params
    if @locality.save
      flash[:notice] = "Added the new locality."
      redirect_to action: :index
    else
      flash[:errors] = "Sorry couldn't do it."
      render action: :new
    end
  end

  def edit
    @locality = Locality.find params[:id]
  end

  def update
    @locality = Locality.find params[:id]
    if @locality.update resource_params
      flash[:notice] = "Updated the locality."
      redirect_to action: :index
    else
      flash[:errors] = "Sorry couldn't do it."
      render action: :edit
    end
  end

  def destroy
    @locality = Locality.find params[:id]
    if @locality.destroy
      flash[:notice] = "Deleted the locality."
      redirect_to action: :index
    else
      flash[:errors] = "Sorry couldn't do it."
      redirect_back fallback_location: { action: :index }
    end
  end

  private

  def resource_params
    params.require(:locality).permit!
  end
end