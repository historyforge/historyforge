class People::CensusRecordsNineteenTwentyController < People::CensusRecordsController
  def resource_path(*args)
    census1920_record_path(*args)
  end

  def edit_resource_path(*args)
    edit_census1920_record_path(*args)
  end

  def new_resource_path(*args)
    new_census1920_record_path(*args)
  end

  def save_as_resource_path(*args)
    save_as_census1920_record_path(*args)
  end

  def reviewed_resource_path(*args)
    reviewed_census1920_record_path(*args)
  end

  def collection_path(*args)
    census1920_records_path(*args)
  end

  def unreviewed_collection_path(*args)
    unreviewed_census1920_records_path(*args)
  end

  def unhoused_collection_path(*args)
    unhoused_census1920_records_path(*args)
  end

  def year
    1920
  end

  private

  def resource_class
    Census1920Record
  end

  def page_title
    '1920 US Census Records'
  end

  def census_record_search_class
    CensusRecord1920Search
  end
end
