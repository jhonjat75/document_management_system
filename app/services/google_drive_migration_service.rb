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

    # Estrategia correcta: iterar sobre documentos en BD, no sobre archivos en Drive
    documents = Document.where.not(google_file_id: nil)
    @stats[:total] = documents.count

    puts "Total de documentos en BD con google_file_id: #{@stats[:total]}"
    puts ""

    documents.each_with_index do |document, index|
      puts "[#{index + 1}/#{@stats[:total]}] Procesando documento: #{document.name || document.title || 'Sin nombre'}"

      begin
        old_file_id = document.google_file_id
        
        if dry_run
          puts "  [DRY RUN] google_file_id actual: #{old_file_id}"
          puts "  [DRY RUN] ✓ Se migraría este documento"
          @stats[:skipped] += 1
        else
          # Intentar copiar el archivo desde su ubicación actual (por ID)
          # Google Drive permite copiar archivos incluso si ya están en otras carpetas
          new_file_id = migrate_file_by_id(old_file_id, document.name || document.title || '')
          
          if new_file_id
            puts "  ✓ Archivo copiado (ID nuevo: #{new_file_id})"
          else
            puts "  ⚠ No se pudo copiar el archivo (puede no existir, estar en otra ubicación, o ya estar en destino)"
            @stats[:skipped] += 1
            puts ""
            next
          end
          
          if update_documents && new_file_id
            document.update(google_file_id: new_file_id)
            puts "  ✓ Documento actualizado en BD"
          end
          
          @stats[:migrated] += 1
        end
      rescue => e
        @stats[:failed] += 1
        error_msg = "#{document.name || document.id}: #{e.message}"
        @stats[:errors] << error_msg
        puts "  ✗ Error: #{e.message}"
      end
      
      puts ""
    end

    print_summary
    @stats
  end

  def migrate_file_by_id(file_id, file_name)
    # Copiar archivo por su ID directamente (no necesita estar en la carpeta origen)
    new_file_id = @drive_service.copy_file_to_folder(
      file_id,
      @destination_folder_id,
      new_name: file_name
    )
    
    return nil unless new_file_id
    
    @drive_service.share_publicly(new_file_id)
    
    new_file_id
  rescue
    # Si el archivo no existe o hay error, retornar nil
    nil
  end

  private

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

