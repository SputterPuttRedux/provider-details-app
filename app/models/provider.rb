class Provider < ApplicationRecord
    self.primary_key = "npid"

    has_many :providers_users, class_name: 'ProviderUser'
    has_many :users, through: :providers_users

    validates   :first_name,
                :last_name,
                :taxonomy,
                :address_1,
                :city,
                :state,
                :postal_code,
                :enumeration_type, presence: true
end
