class Census1930Record < CensusRecord
  self.table_name = 'census_1930_records'

  belongs_to :coded_industry, class_name: 'Industry1930Code', optional: true, foreign_key: :industry1930_code_id
  belongs_to :coded_occupation, class_name: 'Occupation1930Code', optional: true, foreign_key: :occupation1930_code_id
  belongs_to :locality, inverse_of: :census1930_records

  before_validation :handle_profession_code, if: :profession_code_changed?
  validates :mother_tongue, vocabulary: { name: :language, allow_blank: true }
  validates :dwelling_number, presence: true

  define_enumeration :worker_class, %w{E W OA NP}
  define_enumeration :war_fought, %w{WW Sp Civ Phil Box Mex}
  define_enumeration :race, %w{W Neg Mex In Ch Jp Fil Hin Kor}
  define_enumeration :relation_to_head, %w{Head Wife Son Daughter Lodger Roomer Boarder Sister Servant}
  define_enumeration :name_suffix, %w{Jr Sr}
  define_enumeration :name_prefix, %w{Dr Mr Mrs}

  auto_strip_attributes :industry, :profession_code, :pob_code, :worker_class

  def year
    1930
  end

  # def set_defaults
  #   self.pob_code ||= 56
  # end

  def coded_occupation_name
    coded_occupation&.name_with_code
  end

  def coded_industry_name
    coded_industry&.name_with_code
  end

  def handle_profession_code
    return if profession_code.blank?
    code = profession_code.squish.split(' ').join.gsub('O', '0')
    ocode = if code =~ /^(8|9)/
              "#{code[0..1]} #{code[2..3]}"
            else
              code[0..1]
            end
    self.coded_occupation = Occupation1930Code.where(code: ocode).first
    icode = code[-2..-1]
    self.coded_industry = Industry1930Code.where(code: icode).first
  end

  def validate_profession_code
    if profession_code.present? && (industry1930_code_id.blank? || occupation1930_code_id.blank?)
      errors.add :profession_code, "Invalid profession code."
    end
  end

  def self.folder_name
    'census_records_nineteen_thirty'
  end
end
