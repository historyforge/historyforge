class CensusFormHint
  def self.generate(klass, field, type)
    new(klass, field, type).generate
  end

  def initialize(klass, field, type)
    @klass = klass
    @field = field
    @type = type
  end

  def generate
    column.present? || text.present? ? "#{column}#{text}".html_safe : false
  end

  attr_reader :klass, :field, :type

  def column
    return @column if defined?(@column)

    @column = klass::COLUMNS[field]

    return unless @column

    @column = case @column
              when /-/
                "<u>Columns #{column}</u><br />"
              when String
                column.length > 1 ? "<u>#{column}</u><br />" : "<u>Column #{column}</u><br />"
              else
                "<u>Column #{column}</u><br />"
              end
  end

  def text
    @text ||= Translator.translate(klass, field, 'hints') ||
      Translator.translate(klass, type || 'string', 'hints')
  end
end
