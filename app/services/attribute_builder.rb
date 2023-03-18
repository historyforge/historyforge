# frozen_string_literal: true

class AttributeBuilder

  def self.boolean(json, key, *args)
    AttributeBuilder::Boolean.new(json:, key:, extras: args.extract_options!).to_json
  end

  # def self.collection(json, klass, key, choices, cols=2, sortable=true)
  def self.collection(json, key, *args)
    options = args.extract_options!
    AttributeBuilder::Collection.new(
      json:,
      klass: options[:klass],
      key:,
      columns: options[:columns],
      extras: { choices: options[:choices] || options[:collection], sortable: options[:sortable] }
    ).to_json
  end

  def self.enumeration(json, klass, key, cols=2)
    AttributeBuilder::Enumeration.new(json:, key:, klass:, columns: cols).to_json
  end

  def self.time(json, key, *args)
    AttributeBuilder::Time.new(json:, key:, extras: args.extract_options!).to_json
  end

  def self.age(json, key, *args)
    AttributeBuilder::Age.new(json:, key:, extras: args.extract_options!).to_json
  end

  def self.number(json, key, *args)
    AttributeBuilder::Number.new(json:, key:, extras: args.extract_options!).to_json
  end

  def self.text(json, key, *args)
    AttributeBuilder::Text.new(json:, key:, extras: args.extract_options!).to_json
  end

end

class AttributeBuilder::BaseAttribute
  attr_accessor :key, :json, :type, :klass

  def initialize(key: nil, json: nil, type: nil, klass: nil, choices: nil, columns: nil, extras: nil)
    @key, @json, @type, @klass, @choices, @columns, @extras = key, json, type, klass, choices, columns, extras
    @klass = @extras.delete(:klass) if @klass.nil? && @extras&.key?(:klass)
    @sortable = @extras&.delete(:sortable)
  end

  def to_json(*_args)
    json.set! key do
      json.type type
      json.label label
      json.scopes do
        scopes
      end
      extras
    end
  end

  def scopes; end

  def label
    filter_translation || label_translation
  end

  def filter_translation
    I18n.t("simple_form.filters.#{@klass ? @klass.name.underscore : nil}.#{key}", default:
      I18n.t("simple_form.filters.census_record.#{key}", default:
        I18n.t("simple_form.filters.defaults.#{key}", default: nil)))
  end

  def label_translation
    I18n.t("simple_form.labels.#{@klass ? @klass.name.underscore : nil}.#{key}", default:
      I18n.t("simple_form.labels.census_record.#{key}", default:
        I18n.t("simple_form.labels.defaults.#{key}", default: (@klass ? @klass : CensusRecord).human_attribute_name(key))))
  end

  def extras
    return unless @extras
    @extras.each do |key, value|
      json.set! key, value
    end
  end
end

class AttributeBuilder::Boolean < AttributeBuilder::BaseAttribute
  def type
    'boolean'
  end

  def scopes
    json.set! "#{key}_true", 'Yes'
    json.set! "#{key}_false", 'No'
    json.set! "#{key}_null", 'Blank'
  end
end

class AttributeBuilder::Enumeration < AttributeBuilder::BaseAttribute
  def type
    'checkboxes'
  end

  def scopes
    json.set! "#{key}_in".to_sym, 'is one of'
    json.set! "#{key}_not_in".to_sym, 'is not one of'
    json.set! "#{key}_null".to_sym, 'is blank'
    json.set! "#{key}_not_null", 'is not blank'
  end

  def extras
    super
    json.choices choices
    json.columns @columns
    json.sortable(key_name) if @sortable
  end

  def choices
    klass.send("#{key}_choices").map do |item|
      [I18n.t("census_codes.#{key}.#{item.downcase}", default: item), item]
    end.concat(key == :page_side ? [] : [['Left blank', 'blank'], %w[Unknown unknown]])
  end
end

class AttributeBuilder::Collection < AttributeBuilder::Enumeration
  def choices
    @extras.delete :choices
  end

  def key_name
    key
  end

  def extras
    super
    json.sortable(key) if @sortable
  end
end

class AttributeBuilder::Number < AttributeBuilder::BaseAttribute
  def type
    'number'
  end

  def scopes
    json.set! "#{key}_eq".to_sym, 'equals'
    json.set! "#{key}_lt".to_sym, 'less than'
    json.set! "#{key}_lteq".to_sym, 'less than or equal to'
    json.set! "#{key}_gteq".to_sym, 'greater than or equal to'
    json.set! "#{key}_gt".to_sym, 'greater than'
    json.set! "#{key}_not_null".to_sym, 'is not blank'
    json.set! "#{key}_null".to_sym, 'is blank'
  end

  def extras
    super
    json.sortable(key) if @sortable != false
  end
end

class AttributeBuilder::Time < AttributeBuilder::Number
  def scopes
    json.set! "#{key}_eq".to_sym, 'equals'
    json.set! "#{key}_lt".to_sym, 'earlier than'
    json.set! "#{key}_lteq".to_sym, 'on or earlier than'
    json.set! "#{key}_gteq".to_sym, 'on or later than'
    json.set! "#{key}_gt".to_sym, 'later than'
    json.set! "#{key}_not_null".to_sym, 'is not blank'
    json.set! "#{key}_null".to_sym, 'is blank'
  end

  def extras
    super
    json.sortable key
  end
end

class AttributeBuilder::Age < AttributeBuilder::Number
  def scopes
    json.set! "#{key}_eq".to_sym, 'equals'
    json.set! "#{key}_lt".to_sym, 'younger than'
    json.set! "#{key}_lteq".to_sym, 'as young or younger than'
    json.set! "#{key}_gteq".to_sym, 'as old or older than'
    json.set! "#{key}_gt".to_sym, 'older than'
    json.set! "#{key}_not_null".to_sym, 'is not blank'
    json.set! "#{key}_null".to_sym, 'is blank'
  end

  def extras
    super
    json.sortable key
  end
end

class AttributeBuilder::Text < AttributeBuilder::BaseAttribute
  def type
    'text'
  end

  def scopes
    json.set! "#{key}_cont", 'contains'
    json.set! "#{key}_not_cont", 'does not contain'
    json.set! "#{key}_start", 'starts with'
    json.set! "#{key}_end", 'ends with'
    json.set! "#{key}_has_any_term".to_sym, 'is one of'
    json.set! "#{key}_has_every_term".to_sym, 'is all of'
    json.set! "#{key}_cont_any_term".to_sym, 'contains one of'
    json.set! "#{key}_cont_every_term".to_sym, 'contains all of'
    json.set! "#{key}_lt".to_sym, 'comes before'
    json.set! "#{key}_gt".to_sym, 'comes after'
    json.set! "#{key}_null".to_sym, 'is blank'
    json.set! "#{key}_not_null", 'is not blank'
  end

  def extras
    super
    json.sortable key
  end
end
