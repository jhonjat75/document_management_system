# frozen_string_literal: true

namespace :test do
  desc 'Probar flujo completo de subida (simula DocumentsController)'
  task :full_upload => :environment do
    puts '=== PRUEBA DE FLUJO COMPLETO DE SUBIDA ==='
    puts ''

    # Simular un archivo subido
    require 'tempfile'

    test_file = Tempfile.new(['test_full', '.pdf'])
    test_file.write("%PDF-1.4\nTest PDF Content")
    test_file.rewind

    class MockUploadedFile
      attr_reader :tempfile, :original_filename, :content_type

      def initialize(tempfile, filename, content_type)
        @tempfile = tempfile
        @original_filename = filename
        @content_type = content_type
      end
    end

    uploaded_file = MockUploadedFile.new(test_file, 'documento_prueba.pdf', 'application/pdf')

    puts '1. Extrayendo archivo del parámetro...'
    puts "   Nombre: #{uploaded_file.original_filename}"
    puts "   Tipo: #{uploaded_file.content_type}"
    puts "   Tamaño: #{test_file.size} bytes"
    puts ''

    puts '2. Validando que el archivo existe...'
    if uploaded_file.blank?
      puts '✗ Archivo en blanco'
      exit 1
    end
    puts '✓ Archivo válido'
    puts ''

    puts '3. Subiendo a Google Drive...'
    begin
      result = GoogleFileUploader.upload(uploaded_file)

      if result && result.file_id.present?
        puts '✓ Archivo subido exitosamente'
        puts "   File ID: #{result.file_id}"
        puts "   Content Type: #{result.content_type}"
        puts ''

        puts '4. Creando documento en BD...'
        folder = Folder.first
        if folder.nil?
          puts '⚠ No hay carpetas en BD, creando una de prueba...'
          folder = Folder.create!(name: 'Carpeta Prueba', description: 'Para pruebas')
        end

        document = Document.new(
          name: uploaded_file.original_filename,
          folder_id: folder.id,
          google_file_id: result.file_id,
          content_type: result.content_type
        )

        if document.save
          puts '✓ Documento guardado en BD'
          puts "   ID: #{document.id}"
          puts "   Nombre: #{document.name}"
          puts "   google_file_id: #{document.google_file_id}"
          puts "   content_type: #{document.content_type}"
          puts ''

          puts '5. Verificando archivo en Drive...'
          service = GoogleDriveService.new
          metadata = service.get_file_metadata(result.file_id)
          puts "   Nombre en Drive: #{metadata.name}"
          puts "   Tipo: #{metadata.mime_type}"
          puts ''

          puts '✅ FLUJO COMPLETO EXITOSO'
          puts ''
          puts "Documento creado:"
          puts "  BD ID: #{document.id}"
          puts "  Drive ID: #{document.google_file_id}"
          puts "  URL: https://drive.google.com/file/d/#{document.google_file_id}/view"
          puts ''
          puts "Para limpiar, elimina el documento con ID #{document.id} y el archivo de Drive"
        else
          puts '✗ Error guardando documento:'
          document.errors.full_messages.each do |error|
            puts "  - #{error}"
          end
        end
      else
        puts '✗ Error: GoogleFileUploader retornó nil o sin file_id'
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
  end
end

