class MarriageStatus1910 < ActiveRecord::Migration[6.0]
  def change
    Census1910Record.where(marital_status: %w{M M1}).each do |row|
      row.marital_status = 'M_or_M1'
      row.save
    end

    Census1910Record.where(marital_status: %w{M2 M3}).each do |row|
      row.marital_status = 'M2_or_M3'
      row.save
    end
  end
end
