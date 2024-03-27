# frozen_string_literal: true

require 'pg'

begin
  connection = PG.connect(
    dbname: 'document_management_system_production',
    user: 'document_management_system',
    password: ENV.fetch('DOCUMENT_MANAGEMENT_SYSTEM_DATABASE_PASSWORD', nil),
    host: '172.22.0.2'
  )
  puts 'Connected to the database successfully!'
rescue PG::Error => e
  puts e.message
ensure
  connection&.close
end
