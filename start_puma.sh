#!/bin/bash

# Cambia al directorio de la aplicación
cd /home/pro/projects/document_management_system

# Inicia Puma en modo producción en segundo plano
RAILS_ENV=production bundle exec puma -C config/puma.rb &

# Guarda el PID del proceso de Puma en un archivo para detenerlo después
echo $! > tmp/pids/puma.pid

echo "Puma iniciado en modo producción"
