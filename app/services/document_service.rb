# frozen_string_literal: true

class DocumentService
  def initialize(document = nil)
    @document = document
  end

  def save
    @document.save
  end

  def destroy
    @document.destroy
  end

  def self.find(id)
    Document.find(id)
  end

  def self.new_document(attributes = {})
    Document.new(attributes)
  end
end
