class CreateProviders < ActiveRecord::Migration[7.0]
  def change
    create_table :providers do |t|
      t.integer :npid
      t.string :first_name
      t.string :last_name
      t.string :taxonomy
      t.string :address_1
      t.string :city
      t.string :state
      t.string :postal_code
      t.string :enumeration_type

      t.timestamps
    end
  end
end
