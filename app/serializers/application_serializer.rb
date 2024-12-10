# frozen_string_literal: true

class ApplicationSerializer
  def initialize(object)
    @object = object
  end

  attr_reader :object

  def serializable_hash
    serializable_attributes.index_with do |attr|
      object.public_send attr
    end
  end

  delegate :as_json, :to_json, to: :serializable_hash

  def serializable_attributes
    []
  end
end
