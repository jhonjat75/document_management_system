# frozen_string_literal: true

Rails.application.routes.draw do
  resources :profiles
  resources :user_profiles
  get 'users/index'
  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }
  get 'profiles',                 to: 'users#profiles'
  root to: "folders#index"
  resources :users do
    member do
      get 'profiles'
    end
  end
  resources :folders
  resources :folders do
    resources :documents, only: [:create, :destroy]
  end
end
