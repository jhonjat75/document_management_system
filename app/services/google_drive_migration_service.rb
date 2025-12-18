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
        if dry_run
          docs_count = Document.where(google_file_id: file.id).count
          puts "  [DRY RUN] Se migraría este archivo"
          puts "  [DRY RUN] Documentos en BD que se actualizarían: #{docs_count}"
          @stats[:skipped] += 1
        else
          new_file_id = migrate_file(file)
          puts "  ✓ Archivo copiado (ID nuevo: #{new_file_id})"
          
          if update_documents && new_file_id
            updated_count = update_document_records(file.id, new_file_id)
            if updated_count > 0
              puts "  ✓ #{updated_count} documento(s) actualizado(s) en BD"
            else
              puts "  ⚠ No hay documentos en BD para este archivo"
            end
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

  def update_document_records(old_file_id, new_file_id)
    documents = Document.where(google_file_id: old_file_id)
    
    documents.each do |document|
      document.update(google_file_id: new_file_id)
    end
    
    documents.count
  end

  def print_summary
    puts "=== RESUMEN DE MIGRACIÓN ==="
    puts "Total de archivos: #{@stats[:total]}"
    puts "Migrados exitosamente: #{@stats[:migrated]}"
    puts "Fallidos: #{@stats[:failed]}"
    puts "Saltados (dry run): #{@stats[:skipped]}"
    puts ""
    
    if @stats[:errors].any?
      puts "Errores encontrados:"
      @stats[:errors].each do |error|
        puts "  - #{error}"
      end
    end
  end
end

