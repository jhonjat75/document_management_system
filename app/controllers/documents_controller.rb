# frozen_string_literal: true

class DocumentsController < ApplicationController
  before_action :set_folder
  before_action :set_document, only: [:destroy]

  def create
    @document = Document.new(document_params)
    @document.folder_id = params[:folder_id]
    if @document.save
      redirect_to folder_path(@document.folder), notice: 'Documento subido con éxito.'
    else
      render 'folders/show', status: :unprocessable_entity
    end
  end

  def destroy
    @document.destroy
    redirect_to folder_path(@folder), notice: 'Documento eliminado con éxito.'
  end

  private

  def set_folder
    @folder = Folder.find(params[:folder_id])
  end

  def set_document
    @document = Document.find(params[:id])
  end

  def document_params
    params.require(:document).permit(:name, :file)
  end
end
