# frozen_string_literal: true

class DocumentsController < ApplicationController
  before_action :set_folder
  before_action :set_document, only: [:destroy]

  def create
    @document = DocumentService.new_document(document_params)
    @document.folder_id = params[:folder_id]

    if DocumentService.new(@document).save
      redirect_to folder_path(@document.folder), notice: 'Documento subido con éxito.'
    else
      render 'folders/show', status: :unprocessable_entity
    end
  end

  def destroy
    DocumentService.new(@document).destroy
    redirect_to folder_path(@folder), notice: 'Documento eliminado con éxito.'
  end

  private

  def set_folder
    @folder = FolderService.find(params[:folder_id])
  end

  def set_document
    @document = DocumentService.find(params[:id])
  end

  def document_params
    params.require(:document).permit(:name, :file, :folder_id)
  end
end
