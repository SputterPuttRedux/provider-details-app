class ProviderDetailsSearch
    include ActiveModel::API
    include ActiveModel::Validations

    NPID_URL = 'https://npiregistry.cms.hhs.gov/api/'.freeze
    NPID_API_VERSION = '2.1'.freeze

    attr_accessor :npid, :session_id

    validate :validate_search

    def search!
       return unless valid?

        create_or_update_provider_user!
        existing_provider || new_provider
    end

    private

    def validate_search
        errors.add(:search, "No results found for NPID #{npid}. Please try again.") if response.nil?
    end

    def create_or_update_provider_user!
        if existing_provider
            if user_previously_searched_for_provider?
                user.providers_users.find_by(provider_id: npid, user_id: session_id).touch(:updated_at)
            else
                user.providers_users.create(provider_id: existing_provider.id)
            end
        else
            new_provider
        end
    end

    def user
        @user ||= User.find_by(session_id: session_id)
    end

    def user_previously_searched_for_provider?
        user.providers_users.find_by(provider_id: npid).present?
    end

    def existing_provider
       @existing_provider ||= Provider.find_by(npid: npid)
    end

    def new_provider
        user.providers.create(provider_params)
    end

    def provider_params
        personal_identifiers.merge(taxonomy).merge(address).merge(npi_type).merge(npi_number)
    end

    def personal_identifiers
        response.fetch("basic").slice("first_name", "last_name")
    end

    def taxonomy
       { "taxonomy" => response.fetch("taxonomies").first.fetch("desc") }
    end

    def address
        response.fetch("addresses").first.except(
            "country_code",
            "country_name",
            "address_purpose",
            "address_type",
            "fax_number",
            "telephone_number"
        )
    end

    def npi_type
        response.slice("enumeration_type")
    end

    def npi_number
        { "id" => npid }
    end
            
    def response
       @response ||= HTTParty.get(
            NPID_URL,
            query: query_params
        ).fetch("results", {}).first
    end

    def query_params
        {
            "number" => npid,
            "version" => NPID_API_VERSION,
        }
    end
end
