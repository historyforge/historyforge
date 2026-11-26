# frozen_string_literal: true

class LocalitiesController < ApplicationController
  include Moveable

  before_action :check_administrator_role, except: %i[set reset]
  before_action :load_coverage_localities, only: %i[census_coverage_import census_coverage_template import_census_coverage]
  before_action :load_census_coverage, only: %i[census_coverage update_census_coverage remove_census_coverage]

  def set
    locality = Locality.find params[:id]
    locality && (session[:locality] = locality.id)
    redirect_back_or_to root_path unless redirect_to_locality_return_path
  end

  def reset
    session.delete(:locality)
    redirect_back_or_to root_path unless redirect_to_locality_return_path
  end

  private def redirect_to_locality_return_path
    return unless (path = url_from(params[:return_to]))

    redirect_to path, status: :see_other
  end

  def index
    @localities = Locality.all
    CensusYears.each do |year|
      ActiveRecord::Precounter.new(@localities).precount(:"census#{year}_records")
    end
  end

  def new
    @locality = Locality.new
  end

  def census_coverages
    @localities = Locality.all
    targets = CensusCoverage.all.to_a
    @targets = targets.index_by { |target| [target.locality_id, target.census_year] }
    return if targets.empty?

    CensusYears.each do |year|
      ActiveRecord::Precounter.new(@localities).precount(:"census#{year}_records")
    end
    @target_totals = targets.group_by(&:census_year).transform_values { |year_targets| year_targets.sum(&:expected_records) }
  end

  def census_coverage_import; end

  def census_coverage_template
    send_data CensusCoverageImporter.template(@coverage_localities),
              filename: 'census-coverage-template.csv', type: 'text/csv; charset=utf-8'
  end

  def import_census_coverage
    upload = params[:file]
    raise ArgumentError, 'Choose a CSV file to upload.' unless upload.is_a?(ActionDispatch::Http::UploadedFile)

    counts = CensusCoverageImporter.new(upload.path).import(apply: true)
    notice = "Import complete. #{counts[:created]} created, #{counts[:updated]} updated, " \
             "#{counts[:unchanged]} unchanged, #{counts[:skipped]} skipped."
    redirect_to census_coverage_import_localities_path, notice:, status: :see_other
  rescue ArgumentError => error
    @import_error = error.message
    render :census_coverage_import, status: :unprocessable_content
  end

  def census_coverage; end

  def update_census_coverage
    attributes = params.require(:census_coverage).permit(:expected_records, :target_basis, :source, :scope_note,
                                                       :verified_complete, :verification_note)
    verified_complete = attributes.delete(:verified_complete)
    @coverage.assign_attributes(attributes)
    unless verified_complete.nil?
      @coverage.set_verification(complete: verified_complete == '1', verifier: current_user)
    end
    if @coverage.save
      redirect_to census_coverage_locality_path(locality, year: @coverage.census_year),
                  notice: 'Coverage target saved.', status: :see_other
    else
      render :census_coverage, status: :unprocessable_content
    end
  end

  def remove_census_coverage
    @coverage.destroy! if @coverage.persisted?
    redirect_to census_coverage_locality_path(locality, year: @coverage.census_year),
                notice: 'Coverage target removed.', status: :see_other
  end

  def edit
    locality
  end

  def create
    @locality = Locality.new resource_params
    if @locality.save
      flash[:notice] = 'Added the new locality.'
      redirect_to action: :index
    else
      render_form_with_errors(:new)
    end
  end

  def update
    if resource.update resource_params
      flash[:notice] = 'Updated the locality.'
      redirect_to action: :index
    else
      render_form_with_errors(:edit)
    end
  end

  def destroy
    if resource.destroy
      flash[:notice] = 'Deleted the locality.'
      redirect_to action: :index
    else
      flash[:error] = "Sorry couldn't do it."
      redirect_back fallback_location: { action: :index }
    end
  end

  private

  def load_coverage_localities
    @coverage_localities = Locality.pluck(:slug, :name)
  end

  def resource_params
    params.require(:locality).permit(:name, :short_name, :latitude, :longitude, :year_street_renumber,
                                    :position, :primary)
  end

  def load_census_coverage
    year = params[:year].presence || CensusYears::YEARS.last.to_s
    unless CensusYears::YEARS.any? { |supported_year| supported_year.to_s == year }
      raise ActiveRecord::RecordNotFound
    end

    @coverages_by_year = locality.census_coverages.index_by(&:census_year)
    @coverage = @coverages_by_year[year.to_i] || locality.census_coverages.build(census_year: year.to_i)
  end

  def locality
    @locality ||= Locality.find(params[:id])
  end

  alias resource locality
end
