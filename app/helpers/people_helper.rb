# frozen_string_literal: true

module PeopleHelper
  def person_record_columns(count)
    return 2 if count <= 2
    return 3 if (count % 3).zero?

    4
  end
end
