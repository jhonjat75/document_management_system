# frozen_string_literal: true

namespace :google_drive do
  desc 'Probar acceso a archivos por google_file_id'
  task :test_file_access, [:limit] => :environment do |_t, args|
    limit = (args[:limit] || 5).to_i
    
    puts '=== PROBANDO ACCESO A ARCHIVOS POR google_file_id ==='
    puts ''
    
    documents = Document.where.not(google_file_id: nil).limit(limit)
    drive_service = GoogleDriveService.new
    
    documents.each do |doc|
      puts "Documento: #{doc.name || doc.title || 'Sin nombre'}"
      puts "  google_file_id: #{doc.google_file_id}"
      
      begin
        metadata = drive_service.get_file_metadata(doc.google_file_id)
        puts "  ✓ Archivo EXISTE en Google Drive"
        puts "    Nombre en Drive: #{metadata.name}"
        puts "    Tipo: #{metadata.mime_type}"
        puts "    Tamaño: #{(metadata.size.to_f / 1_000_000).round(2)} MB" if metadata.size
      rescue => e
        puts "  ✗ Error: #{e.class} - #{e.message}"
        if e.message.include?('notFound') || e.message.include?('404')
          puts "    El archivo NO EXISTE en Google Drive"
        end
      end
      
      puts ''
    end
  end
end

