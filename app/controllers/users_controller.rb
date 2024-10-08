# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[show edit update destroy]

  def index
    @users = UserService.all_users
  end

  def show; end

  def profiles
    @user = User.find(params[:id])
    @user_profiles = @user.user_profiles.includes(:profile)
  end

  def new
    @user = UserService.new_user
  end

  def create
    @user = UserService.new_user(user_params)
    if UserService.new(@user).save
      redirect_to @user, notice: 'Usuario creado exitosamente.'
    else
      render :new
    end
  end

  def edit; end

  def update
    if UserService.new(@user).update(user_params)
      redirect_to @user, notice: 'Usuario actualizado exitosamente.'
    else
      render :edit
    end
  end

  def destroy
    UserService.new(@user).destroy
    redirect_to users_path, notice: 'Usuario eliminado exitosamente.'
  end

  private

  def set_user
    @user = UserService.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :level, :employee_id, :department, :position,
                                 :status, :start_date, :end_date, :address, :role, :password, :password_confirmation)
  end
end
