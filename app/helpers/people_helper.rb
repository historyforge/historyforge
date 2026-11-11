# frozen_string_literal: true

module PeopleHelper
  def person_record_columns(count)
    return 2 if count <= 2
    return 3 if (count % 3).zero?

    4
  end

  def linked_household_records_by_year(households)
    households.values.flat_map(&:fellows).select(&:person_id).group_by(&:year).sort.map do |year, records|
      sorted = records.sort_by { |record| [record.page_number.to_i, record.page_side.to_s, record.line_number.to_i] }
      [year, sorted.uniq(&:person_id)]
    end
  end
end
