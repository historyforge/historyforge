class RemoveMiddleNameWhenFirstNameIdentical < ActiveRecord::Migration[7.0]
  def up
    Person.where('first_name=middle_name').each do |person|
      person.update(middle_name: nil)
    end
  end

  def down
    # do nothing
  end
end
