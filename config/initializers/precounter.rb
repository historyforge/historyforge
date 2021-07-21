ActiveRecord::Precounter.class_eval do
  def precount(association_name, attr_name=nil, &block)
    attr_name ||= association_name

    records = *@relation
    return records if records.empty?

    # We need to get the relation's active class, which is the class itself
    # in the case of a single record.
    klass = @relation.respond_to?(:klass) ? @relation.klass : @relation.class

    association_name = association_name.to_s
    reflection = klass.reflections.fetch(association_name)
    inverse_of = reflection.inverse_of

    primary_key = inverse_of.nil? ? :id : inverse_of.association_primary_key.to_sym

    basis = if reflection.has_scope?
              reflection.scope_for(reflection.klass.unscoped)
            else
              reflection.klass
            end

    basis = block.call(basis) if block_given?

    basis = if reflection.macro == :has_and_belongs_to_many
              basis.joins(inverse_of.name).where(inverse_of.name => { primary_key => records.map(&primary_key) })
            else
              basis.where(inverse_of.name => records.map(&primary_key))
            end
    count_by_id = basis.unscope(:order).group(inverse_of.foreign_key).count
    writer = define_count_accessor(klass, attr_name)
    records.each do |record|
      record.public_send(writer, count_by_id.fetch(record.public_send(primary_key), 0))
    end
  end
end
