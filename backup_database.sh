#!/bin/bash

# Script para hacer backup de la base de datos de producción
# Uso: ./backup_database.sh

set -e

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="backups"
DB_NAME="document_management_system_production"

# Crear directorio de backups si no existe
mkdir -p "$BACKUP_DIR"

# Obtener variables de entorno
DB_USER="${POSTGRES_USER:-postgres}"
DB_PASSWORD="${POSTGRES_PASSWORD}"
DB_HOST="${POSTGRES_HOST:-localhost}"
DB_PORT="${POSTGRES_PORT:-5432}"

# Nombre del archivo de backup
BACKUP_FILE="${BACKUP_DIR}/backup_${DB_NAME}_${TIMESTAMP}.sql"

echo "=== BACKUP DE BASE DE DATOS ==="
echo "Base de datos: $DB_NAME"
echo "Usuario: $DB_USER"
echo "Host: $DB_HOST"
echo "Archivo: $BACKUP_FILE"
echo ""

# Si PGPASSWORD está configurado, usarlo, si no, pedirlo
if [ -z "$DB_PASSWORD" ]; then
    echo "Variable POSTGRES_PASSWORD no encontrada en .env"
    echo "Usando pg_dump con autenticación interactiva..."
    export PGPASSWORD="$DB_PASSWORD"
fi

# Ejecutar pg_dump
echo "Iniciando backup..."
pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -F c -f "${BACKUP_FILE}.dump" 2>/dev/null || \
pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$BACKUP_FILE"

if [ -f "${BACKUP_FILE}.dump" ] || [ -f "$BACKUP_FILE" ]; then
    echo ""
    echo "✅ Backup completado exitosamente!"
    if [ -f "${BACKUP_FILE}.dump" ]; then
        echo "Archivo: ${BACKUP_FILE}.dump"
        ls -lh "${BACKUP_FILE}.dump"
    else
        echo "Archivo: $BACKUP_FILE"
        ls -lh "$BACKUP_FILE"
    fi
else
    echo ""
    echo "❌ Error: No se pudo crear el backup"
    exit 1
fi

