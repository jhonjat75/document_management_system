# frozen_string_literal: true

class DocumentsController < ApplicationController
  before_action :set_folder
  before_action :set_document, only: [:destroy]

  def create
    uploaded_file = params.dig(:document, :upload)
    return deny_upload unless current_user.can_create_folder?(@folder)

    @document = build_document_with(uploaded_file)
    return upload_success if DocumentService.new(@document).save

    render_upload_error
  end

  def destroy
    unless current_user.can_delete_folder?(@folder)
      redirect_to folder_path(@folder), alert: 'No tienes permiso para eliminar archivos.'
      return
    end

    GoogleDriveService.new.delete_file(@document.google_file_id) if @document.google_file_id.present?
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
    params.require(:document).permit(:name, :folder_id)
  end

  def deny_upload
    redirect_to folder_path(@folder), alert: 'No tienes permiso para subir archivos.'
  end

  def build_document_with(file)
    doc = DocumentService.build(document_params)
    doc.user = current_user
    doc.folder_id = @folder.id
    return doc unless file.present?

    apply_upload_result(doc, file)
    doc
  end

  def apply_upload_result(doc, file)
    result = GoogleFileUploader.upload(file)
    doc.google_file_id = result.file_id
    doc.content_type = result.content_type
  end

  def upload_success
    redirect_to folder_path(@document.folder), notice: 'Documento subido a Google Drive.'
  end

  def render_upload_error
    render 'folders/show', status: :unprocessable_entity
  end
end
