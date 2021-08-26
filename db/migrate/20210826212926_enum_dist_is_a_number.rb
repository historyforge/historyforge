class EnumDistIsANumber < ActiveRecord::Migration[6.0]
  def up
    CensusYears.each do |year|
      add_column "census_#{year}_records", :enum_dist_tmp, :integer
      add_column "census_#{year}_records", :ward_tmp, :integer
      "Census#{year}Record".constantize.reset_column_information
      enum_dist = "Census#{year}Record".constantize.pluck('enum_dist').uniq.select(&:present?)
      wards = "Census#{year}Record".constantize.pluck('ward').uniq.select(&:present?)

      enum_dist.each do |dist|
        "Census#{year}Record".constantize.where(enum_dist: dist).update_all enum_dist_tmp: dist.to_i
      end
      wards.each do |ward|
        "Census#{year}Record".constantize.where(ward: ward).update_all ward_tmp: ward.to_i
      end
      rename_column "census_#{year}_records", :enum_dist, :enum_dist_str
      rename_column "census_#{year}_records", :enum_dist_tmp, :enum_dist
      rename_column "census_#{year}_records", :ward, :ward_str
      rename_column "census_#{year}_records", :ward_tmp, :ward
    end
  end
  def down
    CensusYears.each do |year|
    end
  end
end
