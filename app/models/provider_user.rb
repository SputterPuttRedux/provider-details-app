class ProviderUser < ApplicationRecord
    self.table_name = "providers_users"

    belongs_to :user
    belongs_to :provider
end
