# frozen_string_literal: true

class EditRequestsController < ApplicationController
  before_action :set_document, only: %i[new create]
  before_action :authenticate_user!

  def index
    @edit_requests = EditRequest
                     .includes(:document, :user)
                     .order(created_at: :desc)
  end

  def new
    @request = EditRequest.new
  end

  def create
    build_edit_request

    if @request.save
      grant_temporary_edit_access
      flash[:notice] = success_edit_message
      redirect_to @document.folder
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_document
    @folder = Folder.find(params[:folder_id])
    @document = Document.find(params[:document_id])
  end

  def edit_request_params
    params.require(:edit_request).permit(:reason)
  end

  def build_edit_request
    @request = EditRequest.new(edit_request_params)
    @request.document = @document
    @request.user = current_user
    @request.status = 'active'
  end

  def grant_temporary_edit_access
    GoogleDrivePermissionService.new(@document)
                                .grant_edit_access(current_user.email)
  end

  def success_edit_message
    "Se concedió permiso de edición al usuario #{current_user.email} " \
      "para el documento \"#{@document.name}\" por 4 horas. " \
      'Ya puede ingresar y editar el archivo.'
  end
end
