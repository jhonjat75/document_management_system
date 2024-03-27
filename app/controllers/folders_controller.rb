# frozen_string_literal: true

class FoldersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_folder, only: %i[show edit update destroy]
  before_action :authorize_folder, only: %i[show edit update destroy]

  # GET /folders or /folders.json
  def index
    @folders = FolderService.parent_folders
  end

  # GET /folders/1 or /folders/1.json
  def show; end

  # GET /folders/new
  def new
    @folder = FolderService.new_instance(parent_folder_id: params[:parent_folder_id])
  end

  # POST /folders or /folders.json
  def create
    @folder = build_folder
    authorize @folder

    if save_folder
      handle_successful_create
    else
      handle_failed_create
    end
  end

  # PATCH/PUT /folders/1 or /folders/1.json
  def update
    if FolderService.new(@folder).update(folder_params)
      redirect_after_create_or_update
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /folders/1 or /folders/1.json
  def destroy
    FolderService.new(@folder).destroy
    redirect_to folders_url, notice: 'Folder was successfully destroyed.'
  end

  private

  def set_folder
    @folder = FolderService.find(params[:id])
  end

  def authorize_folder
    authorize @folder
  end

  def folder_params
    params.require(:folder).permit(:name, :description, :parent_folder_id)
  end

  def build_folder
    folder = FolderService.new_instance(folder_params)
    folder.user_id = current_user.id
    folder
  end

  def save_folder
    FolderService.new(@folder).save
  end

  def handle_successful_create
    respond_to do |format|
      format.html { redirect_after_create_or_update }
      format.json { render :show, status: :created, location: @folder }
    end
  end

  def handle_failed_create
    respond_to do |format|
      format.html { render :new, status: :unprocessable_entity }
      format.json { render json: @folder.errors, status: :unprocessable_entity }
    end
  end

  def redirect_after_create_or_update
    if @folder.parent_folder_id
      redirect_to folder_path(@folder.parent_folder_id), notice: 'Subfolder was successfully created.'
    else
      redirect_to folders_url, notice: 'Folder was successfully created.'
    end
  end
end
