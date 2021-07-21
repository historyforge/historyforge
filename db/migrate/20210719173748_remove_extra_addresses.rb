class RemoveExtraAddresses < ActiveRecord::Migration[6.0]
  def change
    Address.where(name: nil).each do |address|
      address.destroy
    end
  end
end
