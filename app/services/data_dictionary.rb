class DataDictionary
  def self.census_code(field, code)
    instance.lookup_code(field, code)
  end

  def self.label(field, year)
    instance.lookup(:label, field, year)
  end

  def self.hint(field, year)
    instance.lookup(:hint, field, year)
  end

  def self.filter(field, year)
    instance.lookup(:filter, field, year) || instance.lookup(:label, field, year)
  end

  def self.column(field, year)
    instance.lookup(:column, field, year)
  end

  def self.instance
    @instance ||= new
  end

  def initialize
    file = Rails.root.join('db', 'census-dictionary.json')
    data = JSON.parse(File.open(file).read)
    @dictionary = HashWithIndifferentAccess.new(data)
  end

  def lookup_code(field, item)
    code = item.downcase.gsub(/\W/, '')
    @dictionary[:codes][field][code] || @dictionary[:codes][:defaults][code]
  end

  def lookup(thing, field, year)
    field_config = @dictionary[:fields][field]
    return field.to_s.humanize unless field_config

    (field_config[year.to_s] || {}).reverse_merge(field_config[:defaults])[thing]
  end
end
