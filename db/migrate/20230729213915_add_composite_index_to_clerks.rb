class AddCompositeIndexToClerks < ActiveRecord::Migration[7.0]
  def change
    add_index :clerks, [:registration_date, :id], unique: true
  end
end
