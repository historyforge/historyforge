class Term < ApplicationRecord
  belongs_to :vocabulary
  validates :name, presence: true
  validates :name, uniqueness: { scope: :vocabulary_id }

  before_update :update_census_records

  def is_duplicate?
    !valid? && errors.details[:name].first[:error] == :taken
  end

  def merge!
    update_census_records
    destroy
  end

  def records_for(year)
    fields = relevant_fields_for_year year
    return if fields.blank?

    model_class_for_year(year).where([fields.map { |field| "#{field}=:name" }.join(' OR '), { name: }])
  end

  def count_records_for(year)
    records = records_for(year)
    records&.count
  end

  private

  def update_census_records
    from, to = name_change
    each_relevant_field do |year, attribute|
      model_class_for_year(year).where(attribute => from).each do |census_record|
        census_record[attribute] = to
        census_record.save validate: false
      end
    end
  end

  def model_class_for_year(year)
    "Census#{year}Record".constantize
  end

  def relevant_fields_for_year(year)
    vocabulary.fields_by_year[year]
  end

  def each_relevant_field
    CensusYears.each do |year|
      relevant_fields_for_year(year).each do |attribute|
        yield year, attribute
      end
    end
  end
end
