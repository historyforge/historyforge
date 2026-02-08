# frozen_string_literal: true

# Value object that wraps session[:search] hash to provide a clear interface.
# Rails sessions convert symbol keys to strings, so this handles that conversion.
class SessionSearch
  def initialize(session_data)
    @data = session_data || {}
  end

  def model
    @data['model'] || @data[:model]
  end

  def params
    raw_params = @data['params'] || @data[:params]
    raw_params&.deep_symbolize_keys
  end

  def matches?(search_key)
    model == search_key
  end

  def present?
    @data.present? && params.present?
  end

  def params_with_action(search_key, action)
    return nil unless matches?(search_key)

    params&.merge(action:)
  end

  def to_hash
    {
      'model' => model,
      'params' => @data['params'] || @data[:params]
    }
  end
end
