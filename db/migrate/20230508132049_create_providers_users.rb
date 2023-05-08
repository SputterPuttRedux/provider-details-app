class CreateProvidersUsers < ActiveRecord::Migration[7.0]
  def change
    create_join_table :providers, :users do |t|
      t.primary_key :id
      t.index [:provider_id, :user_id], unique: true

      t.timestamps
    end
  end
end
