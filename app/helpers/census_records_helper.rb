module CensusRecordsHelper
  def editing_users_for(item)
    user_ids = item.versions.map(&:whodunnit).compact.map(&:to_i)
    User.where(id: user_ids).each_with_object({}) { |u, o| o[u.id.to_s] = u.login }
  end

  def census_form_renderer
    "Census#{controller.year}FormFields".constantize
  end

  def translated_label(klass, key)
    Translator.label(klass, key)
  end

  def translated_option(attribute_name, item)
    Translator.option(attribute_name, item)
  end

  def select_options_for(collection)
    [%w[blank nil]] + collection.zip(collection)
  end

  def yes_no_choices
    [['Left blank', nil], ['Yes', true], ['No', false]]
  end

  def yes_no_na(value)
    if value.nil?
      'blank'
    else
      value ? 'yes' : 'no'
    end
  end

  def is_1900?
    controller.year == 1900
  end

  def is_1910?
    controller.year == 1910
  end

  def is_1920?
    controller.year == 1920
  end

  def is_1930?
    controller.year == 1930
  end

  def is_1940?
    controller.year == 1940
  end
end
