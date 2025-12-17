# frozen_string_literal: true

namespace :google_drive do
  desc 'Migrar archivos de una carpeta antigua a una carpeta nueva en Shared Drive y actualizar BD'
  task :migrate, %i[source_folder_id destination_folder_id] => :environment do |_t, args|
    source_folder_id = args[:source_folder_id] || ENV['GOOGLE_DRIVE_OLD_FOLDER_ID'] || '1FIqYgvRuNXLJxA52LcRNCW_H1FuZ14sD'
    destination_folder_id = args[:destination_folder_id] || ENV.fetch('GOOGLE_DRIVE_FOLDER_ID', nil)

    if destination_folder_id.nil?
      puts 'ERROR: Debes especificar destination_folder_id o configurar GOOGLE_DRIVE_FOLDER_ID'
      exit 1
    end

    puts '=== MIGRACIÓN DE ARCHIVOS DE GOOGLE DRIVE ==='
    puts "Carpeta origen: #{source_folder_id}"
    puts "Carpeta destino: #{destination_folder_id}"
    puts ''
    puts 'Este proceso va a:'
    puts '  1. Copiar todos los archivos de la carpeta antigua a la nueva'
    puts '  2. Actualizar automáticamente los google_file_id en la BD'
    puts '  3. Compartir públicamente los nuevos archivos'
    puts ''
    print '¿Continuar con la migración real? (s/n): '

    response = STDIN.gets.chomp.downcase
    unless %w[s y].include?(response)
      puts 'Migración cancelada.'
      exit 0
    end

    puts ''
    puts 'Iniciando migración...'
    puts ''

    service = GoogleDriveMigrationService.new(
      source_folder_id: source_folder_id,
      destination_folder_id: destination_folder_id
    )

    stats = service.migrate_all(
      dry_run: false,
      update_documents: true
    )

    puts ''
    if stats[:failed] > 0
      puts "⚠️  ATENCIÓN: #{stats[:failed]} archivo(s) fallaron. Revisa los errores arriba."
      exit 1
    else
      puts '✅ Migración completada exitosamente!'
    end
  end

  desc 'DRY RUN: Ver qué archivos se migrarían sin hacer cambios reales'
  task :dry_run, %i[source_folder_id destination_folder_id] => :environment do |_t, args|
    source_folder_id = args[:source_folder_id] || ENV['GOOGLE_DRIVE_OLD_FOLDER_ID'] || '1FIqYgvRuNXLJxA52LcRNCW_H1FuZ14sD'
    destination_folder_id = args[:destination_folder_id] || ENV.fetch('GOOGLE_DRIVE_FOLDER_ID', nil)

    if destination_folder_id.nil?
      puts 'ERROR: Debes especificar destination_folder_id o configurar GOOGLE_DRIVE_FOLDER_ID'
      exit 1
    end

    puts '=== DRY RUN: SIMULACIÓN DE MIGRACIÓN ==='
    puts "Carpeta origen: #{source_folder_id}"
    puts "Carpeta destino: #{destination_folder_id}"
    puts 'Modo: DRY RUN (no se realizarán cambios reales)'
    puts ''

    service = GoogleDriveMigrationService.new(
      source_folder_id: source_folder_id,
      destination_folder_id: destination_folder_id
    )

    service.migrate_all(dry_run: true, update_documents: false)
  end

  desc 'Listar archivos en una carpeta de Google Drive'
  task :list_files, [:folder_id] => :environment do |_t, args|
    folder_id = args[:folder_id] || ENV.fetch('GOOGLE_DRIVE_FOLDER_ID', nil)

    if folder_id.nil?
      puts 'ERROR: Debes especificar folder_id o configurar GOOGLE_DRIVE_FOLDER_ID'
      exit 1
    end

    drive_service = GoogleDriveService.new
    files = drive_service.list_files_in_folder(folder_id)

    puts '=== ARCHIVOS EN LA CARPETA ==='
    puts "Folder ID: #{folder_id}"
    puts "Total de archivos: #{files.count}"
    puts ''

    files.each_with_index do |file, index|
      size_mb = file.size ? (file.size.to_f / 1_000_000).round(2) : 'N/A'
      puts "#{index + 1}. #{file.name}"
      puts "   ID: #{file.id}"
      puts "   Tipo: #{file.mime_type}"
      puts "   Tamaño: #{size_mb} MB" if file.size
      puts "   Creado: #{file.created_time}" if file.created_time
      puts ''
    end
  end
end
