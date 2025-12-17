# frozen_string_literal: true

class FoldersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_folder, only: %i[show edit update destroy]

  # GET /folders or /folders.json
  def index
    ExpireEditRequestsService.call
    @folders = FolderService.parent_folders(current_user)
    @can_create_folder = current_user.admin? || current_user.user_profiles.exists?(can_create: true)
  end

  # GET /folders/1 or /folders/1.json
  def show
    @can_create = can_create?
    @can_edit = can_edit?
    @can_delete = can_delete?
  end

  # GET /folders/new
  def new
    @folder = FolderService.new_instance(parent_folder_id: params[:parent_folder_id])
  end

  # POST /folders or /folders.json
  def create
    @folder = build_folder

    if @folder.parent_folder_id.present?
      @folder.profile_ids = parent_folder_profile_ids
    else
      profile_ids_param = folder_params[:profile_ids] || []
      profile_ids_param = [profile_ids_param] unless profile_ids_param.is_a?(Array)
      @folder.profile_ids = profile_ids_param.reject(&:blank?) if profile_ids_param.any?
    end

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
    parent_id = @folder.parent_folder_id
    FolderService.new(@folder).destroy

    if parent_id.present?
      redirect_to folder_path(parent_id), notice: 'Subcarpeta eliminada correctamente.'
    else
      redirect_to folders_url, notice: 'Carpeta eliminada correctamente.'
    end
  end

  private

  def set_folder
    @folder = FolderService.find(params[:id])
  end

  def folder_params
    params.require(:folder).permit(:name, :description, :parent_folder_id, :profile_id, profile_ids: [])
  end

  def build_folder
    folder = FolderService.new_instance(folder_params)

    folder.user_id = current_user.id
    folder
  end

  def save_folder
    FolderService.new(@folder).save
  end

  def parent_folder_profile_ids
    parent_folder = Folder.find(@folder.parent_folder_id)
    parent_folder.profile_ids
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

  def can_create?
    current_user.admin? || current_user.user_profiles.where(profile_id: @folder.profile_ids).exists?(can_create: true)
  end

  def can_edit?
    current_user.admin? || current_user.user_profiles.where(profile_id: @folder.profile_ids).exists?(can_update: true)
  end

  def can_delete?
    current_user.admin? || current_user.user_profiles.where(profile_id: @folder.profile_ids).exists?(can_delete: true)
  end
end
