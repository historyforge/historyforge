class WagesOrSalaryOn1940Census < ActiveRecord::Migration[7.0]
  def change
    change_table :census_1940_records do |t|
      t.string :wages_or_salary, after: :income
    end
    reversible do |dir|
      dir.up do
        Census1940Record.find_each do |record|
          record.wages_or_salary = if record.income == 999
                                     'Un'
                                   elsif record.income_plus?
                                     '5000+'
                                   elsif record.income.nil?
                                     nil
                                   else
                                     record.income.to_s
                                   end
          record.save
        end
      end
    end
  end
end
