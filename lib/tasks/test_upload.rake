# frozen_string_literal: true

namespace :test do
  desc 'Probar subida de archivo a Google Drive'
  task :upload => :environment do
    puts '=== PRUEBA DE SUBIDA A GOOGLE DRIVE ==='
    puts ''

    # Crear un archivo temporal de prueba
    require 'tempfile'
    
    test_file = Tempfile.new(['test_upload', '.txt'])
    test_file.write("Archivo de prueba generado el #{Time.now}")
    test_file.rewind

    puts "Archivo temporal creado: #{test_file.path}"
    puts "Tamaño: #{test_file.size} bytes"
    puts ''

    # Crear un objeto que simule ActionDispatch::Http::UploadedFile
    class MockUploadedFile
      attr_reader :tempfile, :original_filename, :content_type

      def initialize(tempfile, filename, content_type)
        @tempfile = tempfile
        @original_filename = filename
        @content_type = content_type
      end
    end

    uploaded_file = MockUploadedFile.new(test_file, 'test_upload.txt', 'text/plain')

    puts 'Probando GoogleDriveService...'
    begin
      service = GoogleDriveService.new
      puts '✓ GoogleDriveService inicializado correctamente'
      puts ''

      puts "Intentando subir archivo a carpeta: #{ENV['GOOGLE_DRIVE_FOLDER_ID']}"
      puts ''

      file_id = service.upload(
        file: uploaded_file,
        name: uploaded_file.original_filename,
        mime_type: uploaded_file.content_type,
        folder_id: ENV.fetch('GOOGLE_DRIVE_FOLDER_ID')
      )

      if file_id
        puts "✓ Archivo subido exitosamente!"
        puts "  File ID: #{file_id}"
        puts ''

        puts 'Intentando compartir públicamente...'
        service.share_publicly(file_id)
        puts '✓ Archivo compartido públicamente'
        puts ''

        puts 'Verificando metadata del archivo...'
        metadata = service.get_file_metadata(file_id)
        puts "  Nombre: #{metadata.name}"
        puts "  Tipo: #{metadata.mime_type}"
        puts "  Tamaño: #{metadata.size} bytes" if metadata.size
        puts ''

        puts '✅ PRUEBA EXITOSA'
        puts "URL del archivo: https://drive.google.com/file/d/#{file_id}/view"
      else
        puts '✗ Error: El método upload retornó nil'
      end
    rescue => e
      puts "✗ ERROR: #{e.class}"
      puts "  Mensaje: #{e.message}"
      puts ''
      puts "Backtrace:"
      puts e.backtrace.first(10).join("\n")
    ensure
      test_file.close
      test_file.unlink
    end

    puts ''
    puts '=== PRUEBA CON GoogleFileUploader ==='
    puts ''

    test_file2 = Tempfile.new(['test_upload2', '.txt'])
    test_file2.write("Segunda prueba #{Time.now}")
    test_file2.rewind

    uploaded_file2 = MockUploadedFile.new(test_file2, 'test_upload2.txt', 'text/plain')

    begin
      result = GoogleFileUploader.upload(uploaded_file2)
      
      if result && result.file_id
        puts "✓ GoogleFileUploader funcionó correctamente"
        puts "  File ID: #{result.file_id}"
        puts "  Content Type: #{result.content_type}"
        puts "URL: https://drive.google.com/file/d/#{result.file_id}/view"
      else
        puts '✗ Error: GoogleFileUploader retornó nil o sin file_id'
      end
    rescue => e
      puts "✗ ERROR: #{e.class}"
      puts "  Mensaje: #{e.message}"
      puts e.backtrace.first(10).join("\n")
    ensure
      test_file2.close
      test_file2.unlink
    end
  end
end

