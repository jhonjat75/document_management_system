# frozen_string_literal: true

class UserProfile < ApplicationRecord
  belongs_to :user
  belongs_to :profile

  validates :can_create, :can_read, :can_update, :can_delete, inclusion: { in: [true, false] }
end
