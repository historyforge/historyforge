# frozen_string_literal: true

class Census1950RecordsWagesOrSalarySelfP6 < ActiveRecord::Migration[7.2]
  def change
    Census1950Record.where(wages_or_salary_self: "p6").each do |record|
      record.update(wages_or_salary_self: "P6")
    end
  end
end
