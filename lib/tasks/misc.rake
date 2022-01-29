task fixit: :environment do
  dead_terms = []
  undead_terms = []
  [
    ['Language Spoken', 'language'],
    ['Place of Birth', 'pob'],
    ['Relation to Head', 'relation_to_head']
  ].each do |item|
    file = File.open(Rails.root.join('db', "#{item[0]}.csv"))
    vocabulary = Vocabulary.find_by(name: item[0], machine_name: item[1])
    terms = Set.new vocabulary.terms.pluck('name')

    original_terms = Set.new
    CSV.foreach(file, headers: false) do |row|
      original_terms << row[0]
    end

    terms_to_delete = terms - original_terms

    terms_to_delete.each do |name|
      term = vocabulary.terms.find_by(name:)
      counts = 0
      CensusYears.each do |year|
        counts += (term.count_records_for(year) || 0)
      end
      if counts.zero?
        term.destroy
        puts "Deleted #{name}"
        dead_terms << name
      else
        puts "Left #{name} because #{counts} records attached"
        undead_terms << name
      end

    end
  end
  puts "#{dead_terms.length} deleted: #{dead_terms.join(', ')}"
  puts "#{undead_terms.length} not deleted: #{undead_terms.join(', ')}"
end
