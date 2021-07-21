class Vocabulary < ApplicationRecord
  has_many :terms, dependent: :destroy
  validates :name, :machine_name, presence: true
  default_scope -> { order :name }

  def term_exists?(term)
    terms.where(name: term).exists?
  end

  def self.by_name(name)
    where(machine_name: name).first
  end

  def self.controlled_attribute_for(year, attribute)
    DICTIONARY.each do |vocab, years|
      years[year].each do |field|
        return by_name(vocab) if field == attribute
      end
    end
    nil
  end

  def fields_by_year
    DICTIONARY[machine_name.intern]
  end

  DICTIONARY = {
      # industry: {
      #     1900 => ['industry'],
      #     1910 => ['industry'],
      #     1920 => ['industry'],
      #     1930 => ['industry']
      # },
      language: {
          1900 => ['language_spoken'],
          1910 => ['language_spoken'],
          1920 => ['mother_tongue', 'mother_tongue_father', 'mother_tongue_mother'],
          1930 => ['mother_tongue'],
          1940 => ['mother_tongue']
      },
      pob: {
          1900 => ['pob', 'pob_father', 'pob_mother'],
          1910 => ['pob', 'pob_father', 'pob_mother'],
          1920 => ['pob', 'pob_father', 'pob_mother'],
          1930 => ['pob', 'pob_father', 'pob_mother'],
          1940 => ['pob', 'pob_father', 'pob_mother']
      },
      # profession: {
      #     1900 => ['profession'],
      #     1910 => ['profession'],
      #     1920 => ['profession'],
      #     1930 => ['profession']
      # },
      relation_to_head: {
          1900 => ['relation_to_head'],
          1910 => ['relation_to_head'],
          1920 => ['relation_to_head'],
          1930 => ['relation_to_head'],
          1940 => ['relation_to_head']
      },
  }

end
