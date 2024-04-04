# frozen_string_literal: true

class FoldersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_folder, only: %i[show edit update destroy]

  # GET /folders or /folders.json
  def index
    @folders = Folder.where(parent_folder_id: nil)
  end

  # GET /folders/1 or /folders/1.json
  def show
    authorize @folder
  end

  # GET /folders/new
  def new
    @folder = Folder.new
    @folder.parent_folder_id = params[:parent_folder_id]
  end

  # GET /folders/1/edit
  def edit; end

  # POST /folders or /folders.json
  def create
    authorize @folder
    @folder = Folder.new(folder_params)
    @folder.user_id = current_user.id

    respond_to do |format|
      if @folder.save
        if @folder.parent_folder_id
          format.html do
            redirect_to folder_path(@folder.parent_folder_id), notice: 'Subfolder was successfully created.'
          end
        else
          format.html { redirect_to folders_url, notice: 'Folder was successfully created.' }
        end
        format.json { render :show, status: :created, location: @folder }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @folder.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /folders/1 or /folders/1.json
  def update
    authorize @folder
    respond_to do |format|
      if @folder.update(folder_params)
        if @folder.parent_folder_id
          format.html do
            redirect_to folder_path(@folder.parent_folder_id), notice: 'Subfolder was successfully updated.'
          end
        else
          format.html { redirect_to folders_url, notice: 'Folder was successfully updated.' }
        end
        format.json { render :show, status: :ok, location: @folder }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @folder.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /folders/1 or /folders/1.json
  def destroy
    authorize @folder
    @folder.destroy

    respond_to do |format|
      format.html { redirect_to folders_url, notice: 'Folder was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_folder
    @folder = Folder.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def folder_params
    params.require(:folder).permit(:name, :description, :user_id, :parent_folder_id)
  end
end
