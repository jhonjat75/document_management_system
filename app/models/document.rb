# frozen_string_literal: true

class Document < ApplicationRecord
  belongs_to :folder
  belongs_to :user, optional: true
end
