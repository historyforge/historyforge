Ransack.configure do |config|
  config.options[:sanitize_scope_args] = false
  config.add_predicate 'has_any_term',
                       arel_predicate: 'matches_any',
                       formatter: proc { |v| v.scan(/\"(.*?)\"|(\w+)/).flatten.compact },
                       validator: proc { |v| v.present? },
                       type: :string
  config.add_predicate 'cont_any_term',
                       arel_predicate: 'matches_any',
                       formatter: proc { |v| v.scan(/\"(.*?)\"|(\w+)/).flatten.compact.map{|t| "%#{t}%"} },
                       validator: proc { |v| v.present? },
                       type: :string
  config.add_predicate 'has_every_term',
                       arel_predicate: 'matches_all',
                       formatter: proc { |v| v.scan(/\"(.*?)\"|(\w+)/).flatten.compact },
                       validator: proc { |v| v.present? },
                       type: :string
  config.add_predicate 'cont_every_term',
                       arel_predicate: 'matches_all',
                       formatter: proc { |v| v.scan(/\"(.*?)\"|(\w+)/).flatten.compact.map{|t| "%#{t}%"} },
                       validator: proc { |v| v.present? },
                       type: :string
end

Ransack::Search.class_eval do
  def self.human_attribute_name(attribute)
    attribute.to_s.titleize
  end
end
