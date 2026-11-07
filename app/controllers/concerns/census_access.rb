# frozen_string_literal: true

module CensusAccess
  def can_census?(year)
    Setting.can_view_public?(year) || (user_signed_in? && Setting.can_view_private?(year))
  end

  private

  def census_record_readable?(record)
    can_census?(record.year) && can?(:read, record)
  end
end
