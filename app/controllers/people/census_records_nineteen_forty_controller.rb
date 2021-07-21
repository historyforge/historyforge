class People::CensusRecordsNineteenFortyController < People::CensusRecordsController
  def resource_path(*args)
    census1940_record_path(*args)
  end

  def edit_resource_path(*args)
    edit_census1940_record_path(*args)
  end

  def new_resource_path(*args)
    new_census1940_record_path(*args)
  end

  def save_as_resource_path(*args)
    save_as_census1940_record_path(*args)
  end

  def reviewed_resource_path(*args)
    reviewed_census1940_record_path(*args)
  end

  def collection_path(*args)
    census1940_records_path(*args)
  end

  def unreviewed_collection_path(*args)
    unreviewed_census1940_records_path(*args)
  end

  def unhoused_collection_path(*args)
    unhoused_census1940_records_path(*args)
  end

  def year
    1940
  end

  private

  def resource_class
    Census1940Record
  end

  def page_title
    '1940 US Census Records'
  end

  def census_record_search_class
    CensusRecord1940Search
  end
end
