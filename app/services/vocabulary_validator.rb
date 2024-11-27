# frozen_string_literal: true

class VocabularyValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    vocab_name = options[:with] || options[:name] || attribute
    vocabulary = Vocabulary.by_name(vocab_name)
    return if vocabulary&.term_exists?(value)

    vocab_name = vocab_name.to_s.titleize
    record.errors.add attribute, "is not yet in the controlled vocabulary. Please enter X in the #{vocab_name} field and enter the #{vocab_name} from the census in the notes field."
  end
end
