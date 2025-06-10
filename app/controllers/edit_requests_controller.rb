# frozen_string_literal: true

class EditRequestsController < ApplicationController
  before_action :set_document
  before_action :authenticate_user!

  def new
    @request = EditRequest.new
  end

  def create
    @request = EditRequest.new(edit_request_params)
    @request.document = @document
    @request.user = current_user
    @request.status = 'active'

    if @request.save
      GoogleDrivePermissionService.new(@document).grant_edit_access(current_user.email)
      redirect_to @document.folder, notice: 'Permiso de edición concedido temporalmente.'
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
end
