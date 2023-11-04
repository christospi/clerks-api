class CreateClerks < ActiveRecord::Migration[7.0]
  def change
    create_table :clerks do |t|
      t.string :first_name
      t.string :last_name
      t.string :email, limit: 128
      t.string :phone, limit: 32
      t.datetime :registration_date

      t.timestamps
    end

    add_index :clerks, :email, unique: true
  end
end
