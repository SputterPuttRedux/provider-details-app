class ProvidersController < ApplicationController
    before_action :load_providers, only: [:index]
  
    def search
      respond_to do |format|
        if provider_details_search.valid?
          provider_details_search.search!
  
          format.html { redirect_to providers_path }
          format.js {}
        else
          format.html { redirect_to providers_path, flash: { :error => provider_details_search.errors.full_messages.first } }
        end
      end
    end
  
    private
  
    def load_providers
      @providers = current_user.providers.order('providers_users.updated_at desc')
    end
  
    def provider_details_search_params
      params.permit(:npid).merge(session_id: current_user.session_id)
    end
  
    def provider_details_search
      @provider_details_search ||= ProviderDetailsSearch.new(provider_details_search_params)
    end
  end
