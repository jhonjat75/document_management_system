# frozen_string_literal: true

class DocumentsController < ApplicationController
  def create
    @document = Document.new(document_params)
    @document.folder_id = params[:folder_id]
    if @document.save
      redirect_to folder_path(@document.folder), notice: 'Documento subido con éxito.'
    else
      render 'folders/show', status: :unprocessable_entity
    end
  end

  private

  def document_params
    params.require(:document).permit(:name, :file)
  end
end
