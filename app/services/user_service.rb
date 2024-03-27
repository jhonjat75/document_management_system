# frozen_string_literal: true

class UserService
  def initialize(user = nil)
    @user = user
  end

  def save
    @user.save
  end

  def update(attributes)
    @user.update(attributes)
  end

  def destroy
    @user.destroy
  end

  def self.find(id)
    User.find(id)
  end

  def self.new_user(attributes = {})
    User.new(attributes)
  end

  def self.all_users
    User.all
  end
end
