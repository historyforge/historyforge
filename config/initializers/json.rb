# frozen_string_literal: true

class OjEncoder
  attr_reader :options

  def initialize(options = nil)
    @options = options || {}
  end

  # Encode the given object into a JSON string
  def encode(value)
    Oj.dump value.as_json(options.dup)
  end
end

ActiveSupport::JSON::Encoding.json_encoder = OjEncoder
MultiJson.use(:oj)
Oj.mimic_JSON
