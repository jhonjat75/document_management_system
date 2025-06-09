# frozen_string_literal: true

class DocumentService
  def self.find(id)
    Document.find(id)
  end

  def self.build(params)
    Document.new(params)
  end

  def initialize(document)
    @document = document
  end

  def save
    @document.save
  end

  def destroy
    @document.destroy
  end
end
