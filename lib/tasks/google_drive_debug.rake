# frozen_string_literal: true

namespace :google_drive do
  desc 'DEBUG: Probar diferentes métodos de acceso a archivos'
  task :debug_file_access, [:limit] => :environment do |_t, args|
    limit = (args[:limit] || 3).to_i
    
    puts '=== DEBUG: PROBANDO DIFERENTES MÉTODOS DE ACCESO ==='
    puts ''
    
    documents = Document.where.not(google_file_id: nil).limit(limit)
    drive_service = GoogleDriveService.new
    
    documents.each do |doc|
      puts "=" * 80
      puts "Documento: #{doc.name || doc.title || 'Sin nombre'}"
      puts "google_file_id: #{doc.google_file_id}"
      puts ''
      
      # Método 1: Intentar obtener metadata directamente
      puts "1. Probando get_file_metadata..."
      begin
        metadata = drive_service.get_file_metadata(doc.google_file_id)
        puts "   ✓ EXITOSO - Archivo encontrado"
        puts "     Nombre: #{metadata.name}"
        puts "     Tipo: #{metadata.mime_type}"
        puts "     Tamaño: #{(metadata.size.to_f / 1_000_000).round(2)} MB" if metadata.size
        puts "     Creado: #{metadata.created_time}" if metadata.created_time
      rescue => e
        puts "   ✗ FALLO: #{e.class} - #{e.message[0..100]}"
      end
      puts ''
      
      # Método 2: Intentar listar archivos en la carpeta origen y buscar por ID
      puts "2. Probando buscar en carpeta origen..."
      begin
        source_folder_id = ENV['GOOGLE_DRIVE_OLD_FOLDER_ID'] || '1FIqYgvRuNXLJxA52LcRNCW_H1FuZ14sD'
        files = drive_service.list_files_in_folder(source_folder_id)
        found_file = files.find { |f| f.id == doc.google_file_id }
        if found_file
          puts "   ✓ Archivo encontrado en carpeta origen"
          puts "     Nombre: #{found_file.name}"
        else
          puts "   ✗ Archivo NO encontrado en carpeta origen (se buscaron #{files.count} archivos)"
        end
      rescue => e
        puts "   ✗ Error listando carpeta: #{e.class} - #{e.message[0..100]}"
      end
      puts ''
      
      # Método 3: Intentar URL pública
      puts "3. Verificando URL pública..."
      public_url = "https://drive.google.com/file/d/#{doc.google_file_id}/view"
      puts "   URL: #{public_url}"
      puts "   (Puedes abrir esta URL en el navegador para verificar si está compartida)"
      puts ''
      
      # Método 4: Intentar copiar directamente (sin verificar primero)
      puts "4. Probando copiar archivo directamente..."
      begin
        destination_folder_id = ENV.fetch('GOOGLE_DRIVE_FOLDER_ID', nil)
        if destination_folder_id
          new_id = drive_service.copy_file_to_folder(
            doc.google_file_id,
            destination_folder_id,
            new_name: doc.name || doc.title || 'test'
          )
          puts "   ✓ COPIA EXITOSA - ID nuevo: #{new_id}"
        else
          puts "   ⚠ GOOGLE_DRIVE_FOLDER_ID no configurado, saltando prueba de copia"
        end
      rescue => e
        puts "   ✗ FALLO al copiar: #{e.class} - #{e.message[0..150]}"
      end
      puts ''
      
      puts "=" * 80
      puts ''
    end
  end
end

