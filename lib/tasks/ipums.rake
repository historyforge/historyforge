namespace :ipums do
  task load_1910: :environment do
    filename = '/' + File.join('mnt', 'c', 'Users', 'owner', 'Downloads', 'usa_00004.csv')
    File.open(filename, 'r') do |file|
      csv = CSV.new(file, headers: true)

      while row = csv.shift
        record = IpumsRecord.find_or_initialize_by(histid: row['HISTID'])
        record.data = {}
        row.each do |key, value|
          record.data[key] = value
        end
        record.serial = row['SERIAL'].to_i
        record.year = row['YEAR'].to_i
        record.save
      end
    end
  end

  def find_person(person)
    where = {
      sex: person.sex,
      age: person.age,
      marital_status: person.marital_status,
      race: person.race
    }
    where[:relation_to_head] = 'Head' if person.head?

    pob_vocab = Vocabulary.find 2
    bpl = pob_vocab.terms.find_by(ipums: person.data['BPL'])
    fbpl = pob_vocab.terms.find_by(ipums: person.data['FBPL'])
    mbpl = pob_vocab.terms.find_by(ipums: person.data['MBPL'])
    where[:pob] = bpl.name if bpl
    where[:pob_father] = fbpl.name if fbpl
    where[:pob_mother] = mbpl.name if mbpl

    Census1910Record.where(where)
  end

  task match_1910: :environment do
    records = IpumsRecord.where(year: 1910).to_a.group_by(&:serial)
    records.each do |_serial, members|
      head_member = find_person members.first

      puts "*** FOUND #{head_member.count} matches! ***"
      next if head_member.count == 0

      member_size = members.size
      puts "Looking for a family with #{member_size} members."

      families = []
      head_member.each do |member|
        f = Census1910Record.where(
          dwelling_number: member.dwelling_number,
          family_id: member.family_id
        )
        families << f if f.size == member_size
      end

      puts "Found #{families.size} families with #{member_size} members."

      next if families.size == 0

      if member_size == 1
        if families.size == 1
          head_member.first.update_column :histid, members.first.histid
          next
        end
      else
        ages = members.map(&:age).sort
        families = families.select { |f| f.map(&:age).compact.sort == ages }
        puts "#{families.size} of those families have matching aged members."
      end
    end
  end

  task dictionary: :environment do
    dict = {}
    file = Rails.root.join('db', 'ipums.xml')
    xml = Nokogiri::XML(File.open(file).read)
    xml.css('var').each do |var|
      values = {}
      var.css('catgry').each do |cat|
        key = cat.css('catValu').first.content
        val = cat.css('labl').first.content
        values[key] = val
      end
      dict[var['ID']] = values
    end
    File.open(Rails.root.join('db', 'ipums.json'), 'w') do |file|
      file.write dict.to_json
    end
  end

  task dict_terms: :environment do
    Term.update_all ipums: nil
    dict = JSON.parse File.open(Rails.root.join('db', 'ipums.json')).read
    %w{RELATE BPL LANGUAGE}.each do |vocab|
      dict[vocab].each do |key, value|
        term = Term.find_by(name: value)
        if term
          term.update_column :ipums, key
        end
      end
    end
  end
end
