namespace :people do

  task build_from_1910: :environment do
    Census1910Record.find_each do |record|
      record.generate_person_record! if record.person_id.blank?
    end
  end

end
