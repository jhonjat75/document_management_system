#!/bin/bash

# Obtiene el PID del proceso de Puma desde el archivo
if [ -f tmp/pids/puma.pid ]; then
  PID=$(cat tmp/pids/puma.pid)
  echo "Deteniendo Puma (PID: $PID)..."
  kill -9 $PID
  rm tmp/pids/puma.pid
  echo "Puma detenido"
else
  echo "No se encontró el archivo tmp/pids/puma.pid. ¿Puma está corriendo?"
fi
