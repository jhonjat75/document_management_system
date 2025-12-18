# Instrucciones para Migración en Producción

## Antes de ejecutar

1. **Backup de la base de datos** (CRÍTICO):
   
   **Opción más simple (si tienes variables .env):**
   ```bash
   # Cargar variables de entorno
   export $(cat .env | grep POSTGRES | xargs)
   
   # Ejecutar backup
   pg_dump -h localhost -U $POSTGRES_USER -d document_management_system_production > backup_antes_migracion_$(date +%Y%m%d_%H%M%S).sql
   ```
   
   **O usar el script automatizado:**
   ```bash
   ./backup_database.sh
   ```
   
   **Comando directo usando variables de entorno:**
   ```bash
   mkdir -p backups && PGPASSWORD=$POSTGRES_PASSWORD pg_dump -h localhost -U $POSTGRES_USER -d document_management_system_production > backups/backup_antes_migracion_$(date +%Y%m%d_%H%M%S).sql
   ```
   

2. **Verificar variables de entorno**:
   - `GOOGLE_DRIVE_FOLDER_ID` debe estar configurada con la nueva carpeta (Shared Drive)
   - `GOOGLE_DRIVE_SERVICE_ACCOUNT_JSON` debe estar configurada

3. **ID de carpeta antigua**: `1FIqYgvRuNXLJxA52LcRNCW_H1FuZ14sD`

## Paso 1: (Opcional) Dry Run

Para ver qué archivos se migrarían sin hacer cambios:

```bash
RAILS_ENV=production rails google_drive:dry_run[1FIqYgvRuNXLJxA52LcRNCW_H1FuZ14sD]
```

Esto mostrará qué documentos se procesarían sin hacer cambios reales.

## Paso 2: (Opcional) Limpiar carpeta destino

Si quieres empezar desde cero y eliminar archivos que ya fueron copiados anteriormente:

```bash
RAILS_ENV=production rails google_drive:clean_destination
```

**⚠️ ADVERTENCIA**: Esto eliminará TODOS los archivos de la carpeta destino. Debes escribir "ELIMINAR" para confirmar.

## Paso 3: Ejecutar Migración Real

**IMPORTANTE**: Esto copiará archivos y actualizará la BD. Asegúrate del backup.

```bash
RAILS_ENV=production rails google_drive:migrate[1FIqYgvRuNXLJxA52LcRNCW_H1FuZ14sD]
```

**⚠️ CRÍTICO**: Siempre usa `RAILS_ENV=production` para que se conecte a la base de datos de producción.

El comando:
1. Te pedirá confirmación (escribe 's' y Enter)
2. Obtendrá documentos de BD y archivos de Drive, ambos ordenados por fecha
3. Hará matching 1:1 (primer documento con primer archivo, etc.)
4. Copiará cada archivo de la carpeta antigua a la nueva
5. Actualizará automáticamente los `google_file_id` en la BD con los nuevos IDs
6. Compartirá públicamente cada archivo nuevo
7. Mostrará un resumen final con estadísticas

## Qué hace el proceso

El proceso usa **matching por orden de fecha de creación (1:1)**:

1. **Obtiene documentos de BD** ordenados por `created_at` (ascendente)
2. **Obtiene archivos de Drive** ordenados por `created_time` (ascendente)
3. **Hace matching 1:1**: primer documento con primer archivo, segundo con segundo, etc.
4. **Copia cada archivo** a la nueva carpeta (sin descargar/subir, muy rápido)
5. **Obtiene el nuevo file_id** del archivo copiado
6. **Comparte públicamente** el archivo nuevo
7. **Actualiza automáticamente**: `document.update(google_file_id: file_id_nuevo)`
8. **Mantiene todos los demás campos** (content_type, folder_id, name, etc.)

**Nota**: El matching se basa en el orden de creación. Si el número de documentos en BD no coincide con el número de archivos en Drive, se mostrará una advertencia.

## Tiempo estimado

- ~325 archivos
- ~1-3 segundos por archivo (depende de tamaño)
- **Total estimado: 5-15 minutos**

## Si algo falla

- Los archivos ya copiados quedarán en la nueva carpeta
- Los documentos ya actualizados en BD seguirán con los nuevos IDs
- Puedes re-ejecutar el comando (no duplicará archivos, solo intentará los que faltaron)
- Revisa los errores en el output del comando

## Verificar después de migrar

1. Revisar que los archivos estén en la nueva carpeta
2. Revisar que los previews funcionen en la aplicación
3. Verificar que los enlaces directos funcionen

