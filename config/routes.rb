Rails.application.routes.draw do
  root to: "providers#index"

  resources :providers, only: [:index] do
    post :search, on: :collection
  end
end