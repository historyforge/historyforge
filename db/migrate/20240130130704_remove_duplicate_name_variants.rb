class RemoveDuplicateNameVariants < ActiveRecord::Migration[7.0]
  def up
    Person.preload(:names).find_each do |person|
      names = Set.new
      person.names.each do |name_variant|
        if names.include?(name_variant.name)
          name_variant.destroy
        else
          names << name_variant.name
        end
      end
    end
  end

  def down
    # do nothing
  end
end
