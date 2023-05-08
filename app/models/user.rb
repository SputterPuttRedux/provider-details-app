class User < ApplicationRecord
    self.primary_key = "session_id"

    has_many :providers_users, class_name: 'ProviderUser'
    has_many :providers, through: :providers_users
end
