# frozen_string_literal: true

namespace :test do
  desc 'Probar subida SIN impersonation'
  task :upload_no_impersonation => :environment do
    puts '=== PRUEBA DE SUBIDA SIN IMPERSONATION ==='
    puts ''

    require 'google/apis/drive_v3'
    require 'googleauth'
    require 'tempfile'

    # Inicializar sin impersonation
    json_key_io = File.open(ENV.fetch('GOOGLE_DRIVE_SERVICE_ACCOUNT_JSON'))
    authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: json_key_io,
      scope: ['https://www.googleapis.com/auth/drive']
    )

    # NO usar impersonation
    # authorizer.sub = ENV['GOOGLE_DRIVE_IMPERSONATE_USER']

    begin
      authorizer.fetch_access_token!
      puts '✓ Autorización exitosa (sin impersonation)'
    rescue => e
      puts "✗ Error de autorización: #{e.class} - #{e.message}"
      exit 1
    end

    drive_service = Google::Apis::DriveV3::DriveService.new
    drive_service.authorization = authorizer

    # Crear archivo temporal
    test_file = Tempfile.new(['test_upload', '.txt'])
    test_file.write("Archivo de prueba #{Time.now}")
    test_file.rewind

    folder_id = ENV.fetch('GOOGLE_DRIVE_FOLDER_ID')
    file_name = "test_upload_#{Time.now.to_i}.txt"

    puts "Subiendo archivo '#{file_name}' a carpeta: #{folder_id}"
    puts ''

    begin
      metadata = {
        name: file_name,
        parents: [folder_id]
      }

      uploaded_file = drive_service.create_file(
        metadata,
        upload_source: test_file.path,
        content_type: 'text/plain',
        fields: 'id,name',
        supports_all_drives: true
      )

      puts "✓ Archivo subido exitosamente!"
      puts "  ID: #{uploaded_file.id}"
      puts "  Nombre: #{uploaded_file.name}"
      puts ''

      # Compartir públicamente
      permission = Google::Apis::DriveV3::Permission.new(
        type: 'anyone',
        role: 'reader'
      )
      drive_service.create_permission(
        uploaded_file.id,
        permission,
        supports_all_drives: true
      )
      puts '✓ Archivo compartido públicamente'
      puts ''

      puts "✅ PRUEBA EXITOSA"
      puts "URL: https://drive.google.com/file/d/#{uploaded_file.id}/view"
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

