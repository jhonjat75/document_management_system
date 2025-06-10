# frozen_string_literal: true

class EditRequest < ApplicationRecord
  belongs_to :user
  belongs_to :document
end
