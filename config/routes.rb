# frozen_string_literal: true

Rails.application.routes.draw do
  get 'users/index'
  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }
  root to: "users#index"
  resources :users, only: [:index]
end
