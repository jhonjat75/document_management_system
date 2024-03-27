# frozen_string_literal: true

Rails.application.routes.draw do
  get 'users/index'
  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }
  root to: "folders#index"
  resources :users
  resources :folders
  resources :folders do
    resources :documents, only: [:create, :destroy]
  end
end
