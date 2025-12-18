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
    puts "Estrategia: Matching por orden de fecha de creación (1:1)"
    puts ""

    # Obtener documentos de BD ordenados por fecha de creación
    documents = Document.where.not(google_file_id: nil).order(created_at: :asc)
    @stats[:total] = documents.count

    puts "Total de documentos en BD: #{@stats[:total]}"

    # Obtener archivos de Drive ordenados por fecha de creación
    puts "Obteniendo archivos de Drive..."
    drive_files = @drive_service.list_files_in_folder(@source_folder_id)
    drive_files = drive_files.select { |f| f.created_time }.sort_by { |f| Time.parse(f.created_time.to_s) }
    
    puts "Total de archivos en Drive: #{drive_files.count}"
    puts ""

    if documents.count != drive_files.count
      puts "⚠️  ADVERTENCIA: Número de documentos (#{documents.count}) no coincide con número de archivos (#{drive_files.count})"
      puts "   El matching 1:1 puede no ser preciso."
      puts ""
    end

    # Matching 1:1 por orden de fecha
    [documents.count, drive_files.count].min.times do |index|
      document = documents[index]
      drive_file = drive_files[index]

      puts "[#{index + 1}/#{@stats[:total]}] Documento BD: #{document.name || document.title || 'Sin nombre'}"
      puts "  BD created_at: #{document.created_at}"
      puts "  Drive: #{drive_file.name} (ID: #{drive_file.id})"
      puts "  Drive created_time: #{drive_file.created_time}"

      begin
        if dry_run
          puts "  [DRY RUN] ✓ Se migraría este documento"
          @stats[:skipped] += 1
        else
          # Copiar el archivo a la carpeta destino
          new_file_id = @drive_service.copy_file_to_folder(
            drive_file.id,
            @destination_folder_id
          )

          if new_file_id
            @drive_service.share_publicly(new_file_id)
            puts "  ✓ Archivo copiado (ID nuevo: #{new_file_id})"

            if update_documents
              document.update(google_file_id: new_file_id)
              puts "  ✓ Documento actualizado en BD con nuevo ID"
            end

            @stats[:migrated] += 1
          else
            puts "  ⚠ No se pudo copiar el archivo"
            @stats[:skipped] += 1
          end
        end
      rescue => e
        @stats[:failed] += 1
        error_msg = "#{document.name || document.id}: #{e.message}"
        @stats[:errors] << error_msg
        puts "  ✗ Error: #{e.class} - #{e.message}"
      end

      puts ""
    end

    print_summary
    @stats
  end


  def retry_failed_documents(document_names: [], dry_run: false, update_documents: false)
    puts "=== REINTENTO DE MIGRACIÓN DE ARCHIVOS FALLIDOS ==="
    puts "Documentos a reintentar: #{document_names.join(', ')}"
    puts "Modo dry run: #{dry_run}"
    puts "Actualizar documentos en BD: #{update_documents}"
    puts ""

    documents = Document.where(name: document_names)
    @stats[:total] = documents.count

    if documents.empty?
      puts "❌ No se encontraron documentos con esos nombres."
      return @stats
    end

    puts "Total de documentos encontrados: #{@stats[:total]}"
    puts ""

    # Obtener todos los archivos de Drive ordenados
    puts "Obteniendo archivos de Drive..."
    all_drive_files = @drive_service.list_files_in_folder(@source_folder_id)
    all_drive_files = all_drive_files.select { |f| f.created_time }.sort_by { |f| Time.parse(f.created_time.to_s) }
    
    puts "Total de archivos en Drive: #{all_drive_files.count}"
    puts ""

    documents.each_with_index do |document, doc_index|
      puts "[#{doc_index + 1}/#{@stats[:total]}] Reintentando: #{document.name || document.title || 'Sin nombre'}"
      puts "  BD created_at: #{document.created_at}"

      begin
        # Encontrar el archivo correspondiente por posición en la lista ordenada
        # Necesitamos encontrar la posición de este documento en la lista completa ordenada
        all_documents = Document.where.not(google_file_id: nil).order(created_at: :asc)
        position = all_documents.index(document)
        
        if position.nil? || position >= all_drive_files.count
          raise "No se pudo encontrar la posición correspondiente del archivo en Drive"
        end

        drive_file = all_drive_files[position]
        puts "  Drive: #{drive_file.name} (ID: #{drive_file.id})"
        puts "  Drive created_time: #{drive_file.created_time}"

        if dry_run
          puts "  [DRY RUN] ✓ Se migraría este documento"
          @stats[:skipped] += 1
        else
          new_file_id = @drive_service.copy_file_to_folder(
            drive_file.id,
            @destination_folder_id
          )

          if new_file_id
            @drive_service.share_publicly(new_file_id)
            puts "  ✓ Archivo copiado (ID nuevo: #{new_file_id})"

            if update_documents
              document.update(google_file_id: new_file_id)
              puts "  ✓ Documento actualizado en BD con nuevo ID"
            end

            @stats[:migrated] += 1
          else
            puts "  ⚠ No se pudo copiar el archivo"
            @stats[:skipped] += 1
          end
        end
      rescue => e
        @stats[:failed] += 1
        error_msg = "#{document.name || document.id}: #{e.message}"
        @stats[:errors] << error_msg
        puts "  ✗ Error: #{e.class} - #{e.message}"
      end

      puts ""
    end

    print_summary
    @stats
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

