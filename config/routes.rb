# frozen_string_literal: true

Rails.application.routes.draw do
  get 'users/index'
  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }
  root to: "folders#index"
  resources :users, only: [:index]
  resources :folders
end
