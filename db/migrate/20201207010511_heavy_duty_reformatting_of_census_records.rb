class HeavyDutyReformattingOfCensusRecords < ActiveRecord::Migration[6.0]
  def change
    [Census1900Record, Census1910Record, Census1920Record, Census1930Record, Census1940Record].each do |klass|
      klass.find_each do |record|
        record.validate
        record.save(validate: false) if record.changed?
      end
    end
  end
end
