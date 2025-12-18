# frozen_string_literal: true

class GoogleDriveMigrationService
  def initialize(source_folder_id:, destination_folder_id:)
    @source_folder_id = source_folder_id
    @destination_folder_id = destination_folder_id
    @drive_service = GoogleDriveService.new
    @stats = {
      total: 0,
      migrated: 0,
      failed: 0,
      skipped: 0,
      errors: []
    }
  end

  def migrate_all(dry_run: false, update_documents: false)
    puts "=== MIGRACIÓN DE ARCHIVOS DE GOOGLE DRIVE ==="
    puts "Carpeta origen: #{@source_folder_id}"
    puts "Carpeta destino: #{@destination_folder_id}"
    puts "Modo dry run: #{dry_run}"
    puts "Actualizar documentos en BD: #{update_documents}"
    puts ""

    files = @drive_service.list_files_in_folder(@source_folder_id)
    @stats[:total] = files.count

    puts "Total de archivos encontrados: #{@stats[:total]}"
    puts ""

    files.each_with_index do |file, index|
      puts "[#{index + 1}/#{@stats[:total]}] Procesando: #{file.name}"

      begin
        # Buscar documentos por google_file_id primero
        docs_by_id = Document.where(google_file_id: file.id)
        docs_by_name = Document.where(name: file.name)
        
        # Usar los que coinciden por ID, o si no hay, los que coinciden por nombre
        documents = docs_by_id.any? ? docs_by_id : docs_by_name
        docs_count = documents.count
        
        if dry_run
          puts "  [DRY RUN] Documentos encontrados por ID: #{docs_by_id.count}"
          puts "  [DRY RUN] Documentos encontrados por nombre: #{docs_by_name.count}"
          if docs_count > 0
            puts "  [DRY RUN] ✓ Se migraría este archivo y se actualizarían #{docs_count} documento(s)"
          else
            puts "  [DRY RUN] ⚠ Se saltaría (no tiene documentos en BD)"
            @stats[:skipped] += 1
            puts ""
            next
          end
        else
          # Solo migrar archivos que tienen registros en BD
          if docs_count == 0
            puts "  ⚠ Saltado: No tiene documentos en BD (ni por ID ni por nombre), no se migra"
            @stats[:skipped] += 1
            puts ""
            next
          end
          
          # Verificar si el archivo ya existe en la carpeta destino (por nombre)
          existing_file = find_file_in_destination(file.name)
          
          if existing_file
            puts "  ⚠ Archivo ya existe en destino (ID: #{existing_file.id}), solo actualizando BD"
            new_file_id = existing_file.id
          else
            new_file_id = migrate_file(file)
            puts "  ✓ Archivo copiado (ID nuevo: #{new_file_id})"
          end
          
          if update_documents && new_file_id
            # Actualizar tanto los que coinciden por ID como por nombre
            updated_count = update_document_records(file.id, file.name, new_file_id)
            puts "  ✓ #{updated_count} documento(s) actualizado(s) en BD"
          end
          
          @stats[:migrated] += 1
        end
      rescue => e
        @stats[:failed] += 1
        error_msg = "#{file.name}: #{e.message}"
        @stats[:errors] << error_msg
        puts "  ✗ Error: #{e.message}"
      end
      
      puts ""
    end

    print_summary
    @stats
  end

  def migrate_file(file)
    new_file_id = @drive_service.copy_file_to_folder(
      file.id,
      @destination_folder_id,
      new_name: file.name
    )
    
    return nil unless new_file_id
    
    @drive_service.share_publicly(new_file_id)
    
    new_file_id
  end

  private

  def find_file_in_destination(file_name)
    files = @drive_service.list_files_in_folder(@destination_folder_id)
    files.find { |f| f.name == file_name }
  end

  def update_document_records(old_file_id, file_name, new_file_id)
    # Buscar por ID primero, si no hay resultados, buscar por nombre
    documents = Document.where(google_file_id: old_file_id)
    documents = Document.where(name: file_name) if documents.empty?
    
    documents.each do |document|
      document.update(google_file_id: new_file_id)
    end
    
    documents.count
  end

  def print_summary
    puts "=== RESUMEN DE MIGRACIÓN ==="
    puts "Total de archivos encontrados: #{@stats[:total]}"
    puts "Migrados exitosamente: #{@stats[:migrated]}"
    puts "Saltados (sin documentos en BD): #{@stats[:skipped]}"
    puts "Fallidos: #{@stats[:failed]}"
    puts ""
    
    if @stats[:errors].any?
      puts "Errores encontrados:"
      @stats[:errors].each do |error|
        puts "  - #{error}"
      end
    end
  end
end

