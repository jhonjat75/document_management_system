# frozen_string_literal: true

class UserProfilesController < ApplicationController
  def update
    @user_profile = UserProfile.find(params[:id])
    if @user_profile.update(user_profile_params)
      render json: { status: 'success' }
    else
      render json: { status: 'error', errors: @user_profile.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_profile_params
    params.require(:user_profile).permit(:can_create, :can_read, :can_update, :can_delete)
  end
end
