# frozen_string_literal: true

class DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_document, only: %i[show edit update destroy]

  # GET /documents or /documents.json
  def index
    @documents = Document.all
  end

  # GET /documents/1 or /documents/1.json
  def show
  end

  # GET /documents/new
  def new
    @document = Document.new
  end

  # GET /documents/1/edit
  def edit
  end

  # POST /documents or /documents.json
  def create
    # Extraer el archivo antes de crear el documento (upload no es un atributo del modelo)
    uploaded_file = params[:document]&.dig(:upload)
    
    # Crear documento sin el campo upload
    @document = Document.new(document_params)
    @document.user = current_user if user_signed_in?
    
    # Si viene de ruta anidada, usar el folder_id de la ruta
    @document.folder_id = params[:folder_id] if params[:folder_id].present?
    
    folder_id = @document.folder_id

    # Validar que se haya enviado un archivo
    if uploaded_file.blank?
      @document.errors.add(:upload, 'Debes seleccionar un archivo')
      respond_to do |format|
        format.html { redirect_to folder_path(folder_id), alert: 'Debes seleccionar un archivo para subir.' }
        format.json { render json: { error: 'Debes seleccionar un archivo' }, status: :unprocessable_entity }
      end
      return
    end

    # Procesar archivo y subirlo a Google Drive
    begin
      result = GoogleFileUploader.upload(uploaded_file)
      
      if result && result.file_id.present?
        @document.google_file_id = result.file_id
        @document.content_type = result.content_type
      else
        respond_to do |format|
          format.html { redirect_to folder_path(folder_id), alert: 'Error al subir el archivo a Google Drive. Por favor intenta nuevamente.' }
          format.json { render json: { error: 'No se pudo subir el archivo a Google Drive' }, status: :unprocessable_entity }
        end
        return
      end
    rescue => e
      Rails.logger.error "Error en DocumentsController#create: #{e.class} - #{e.message}"
      respond_to do |format|
        format.html { redirect_to folder_path(folder_id), alert: "Error al procesar el archivo: #{e.message}" }
        format.json { render json: { error: e.message }, status: :unprocessable_entity }
      end
      return
    end

    respond_to do |format|
      if @document.save
        format.html { redirect_to folder_path(folder_id), notice: 'Documento creado exitosamente.' }
        format.json { render :show, status: :created, location: @document }
      else
        format.html { redirect_to folder_path(folder_id), alert: "Error: #{@document.errors.full_messages.join(', ')}" }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /documents/1 or /documents/1.json
  def update
    respond_to do |format|
      if @document.update(document_params)
        format.html { redirect_to @document, notice: 'Document was successfully updated.' }
        format.json { render :show, status: :ok, location: @document }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /documents/1 or /documents/1.json
  def destroy
    folder_id = @document.folder_id
    
    # Eliminar el archivo de Google Drive si existe
    if @document.google_file_id.present?
      begin
        GoogleDriveService.new.delete_file(@document.google_file_id)
      rescue => e
        Rails.logger.error "Error eliminando archivo de Google Drive: #{e.message}"
      end
    end
    
    @document.destroy

    respond_to do |format|
      if folder_id.present?
        format.html { redirect_to folder_path(folder_id), notice: 'Documento eliminado exitosamente.' }
      else
        format.html { redirect_to folders_path, notice: 'Documento eliminado exitosamente.' }
      end
      format.json { head :no_content }
    end
  end

  # GET /documents/search
  def search
    query = params[:query]&.strip
    search_in_profiles = params[:search_in_profiles] == 'true'
    search_in_subfolders = params[:search_in_subfolders] == 'true'
    
    if query.blank?
      render json: { results: [] }
      return
    end

    # Construir la consulta base
    documents = Document.joins(:folder)
    
    # Filtrar por perfiles del usuario si es necesario
    if search_in_profiles && !current_user.admin?
      user_profile_ids = current_user.user_profiles.where(can_read: true).pluck(:profile_id)
      documents = documents.joins(folder: :folder_profiles)
                          .where(folder_profiles: { profile_id: user_profile_ids })
    end
    
    # Filtrar por nombre del archivo
    documents = documents.where("documents.name ILIKE ? OR documents.title ILIKE ?", "%#{query}%", "%#{query}%")
    
    # Limitar resultados y ordenar
    documents = documents.limit(20).order(:name)
    
    # Preparar resultados
    results = documents.map do |doc|
      folder_path = build_folder_path(doc.folder, search_in_subfolders)
      
      {
        id: doc.id,
        name: doc.name || doc.title || 'Sin nombre',
        folder_id: doc.folder_id,
        folder_name: doc.folder.name,
        folder_path: folder_path,
        created_at: doc.created_at.strftime("%d/%m/%Y"),
        content_type: doc.content_type
      }
    end
    
    render json: { results: results }
  end

  private

  def set_document
    @document = Document.find(params[:id])
  end

  def document_params
    params.require(:document).permit(:title, :file_path, :folder_id, :user_id, :name, :google_file_id, :content_type)
  end

  def build_folder_path(folder, include_subfolders = true)
    path_parts = []
    current_folder = folder
    
    # Construir ruta desde la carpeta raíz
    while current_folder
      path_parts.unshift(current_folder.name)
      current_folder = current_folder.parent_folder
      
      # Si no incluir subcarpetas, solo mostrar la carpeta actual
      break unless include_subfolders
    end
    
    path_parts.join(' / ')
  end
end
