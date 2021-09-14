namespace :dictionary do
  task build: :environment do
    dict = {
      codes: {},
      fields: {}
    }

    codes = YAML.load_file Rails.root.join('config', 'locales', 'census_codes.yml')
    dict[:codes] = codes['en']['census_codes']

    CensusYears.each do |year|
      "Census#{year}Record".constantize.const_get('COLUMNS').each do |key, value|
        dict[:fields][key.intern] ||= { defaults: {} }
        dict[:fields][key.intern][year] = { column: value }
      end
    end

    labels = YAML.load_file Rails.root.join('config', 'locales', 'census_labels.en.yml')

    labels['en']['simple_form']['filters']['census_record'].each do |key, value|
      dict[:fields][key.intern] ||= { defaults: {} }
      dict[:fields][key.intern][:defaults][:filter] = value
    end

    labels['en']['simple_form']['labels']['census_record'].each do |key, value|
      dict[:fields][key.intern] ||= { defaults: {} }
      dict[:fields][key.intern][:defaults][:label] = value
    end

    CensusYears.each do |year|
      year_labels = labels['en']['simple_form']['labels']["census#{year}_record"]
      year_labels&.each do |key, value|
        dict[:fields][key.intern][year] ||= {}
        dict[:fields][key.intern][year][:label] = value
      end
    end

    hints = YAML.load_file Rails.root.join('config', 'locales', 'census_hints.en.yml')

    hints['en']['simple_form']['hints']['census_record'].each do |key, value|
      dict[:fields][key.intern] ||= { defaults: {} }
      dict[:fields][key.intern][:defaults][:hint] = value
    end

    CensusYears.each do |year|
      year_hints = hints['en']['simple_form']['hints']["census#{year}_record"]
      year_hints&.each do |key, value|
        dict[:fields][key.intern][year] ||= {}
        dict[:fields][key.intern][year][:hint] = value
      end
    end

    filename = Rails.root.join('db', 'census-dictionary.json')
    File.open(filename, 'w') do |file|
      file.write JSON.pretty_generate(dict)
    end
  end
end
