class People::CensusRecordsNineteenAughtController < People::CensusRecordsController
  def resource_path(*args)
    census1900_record_path(*args)
  end

  def edit_resource_path(*args)
    edit_census1900_record_path(*args)
  end

  def new_resource_path(*args)
    new_census1900_record_path(*args)
  end

  def save_as_resource_path(*args)
    save_as_census1900_record_path(*args)
  end

  def reviewed_resource_path(*args)
    reviewed_census1900_record_path(*args)
  end

  def collection_path(*args)
    census1900_records_path(*args)
  end

  def unreviewed_collection_path(*args)
    unreviewed_census1900_records_path(*args)
  end

  def unhoused_collection_path(*args)
    unhoused_census1900_records_path(*args)
  end

  def year
    1900
  end

  private

  def resource_class
    Census1900Record
  end

  def page_title
    '1900 US Census Records'
  end

  def census_record_search_class
    CensusRecord1900Search
  end
end
