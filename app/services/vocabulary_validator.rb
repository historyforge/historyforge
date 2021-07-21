class VocabularyValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    vocab_name = options[:with] || options[:name] || attribute
    vocabulary = Vocabulary.by_name(vocab_name)
    unless vocabulary&.term_exists?(value)
      record.errors.add attribute, 'is not a valid term. If this seems to be an error, please leave blank and make a note'
    end
  end
end