# frozen_string_literal: true

Rails.application.routes.draw do
  resources :folders do
    resources :documents, only: [:create, :destroy] do
      resources :edit_requests, only: [:new, :create]
    end
  end
  resources :edit_requests, only: [:index]

  resources :profiles
  resources :user_profiles

  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }

  resources :users do
    member do
      get 'profiles'
    end
  end

  get 'profiles', to: 'users#profiles'
  root to: 'folders#index'
end
