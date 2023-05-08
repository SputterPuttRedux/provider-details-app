class ChangeDataTypeForUserIdOnProvidersUsers < ActiveRecord::Migration[7.0]
  def change
    change_column(:providers_users, :user_id, :string)
  end
end
