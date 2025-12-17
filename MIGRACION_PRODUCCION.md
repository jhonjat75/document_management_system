# Instrucciones para Migración en Producción

## Antes de ejecutar

1. **Backup de la base de datos** (CRÍTICO):
   ```bash
   # Ejemplo con PostgreSQL
   pg_dump -h localhost -U usuario -d nombre_db > backup_antes_migracion_$(date +%Y%m%d_%H%M%S).sql
   ```

2. **Verificar variables de entorno**:
   - `GOOGLE_DRIVE_FOLDER_ID` debe estar configurada con la nueva carpeta (Shared Drive)
   - `GOOGLE_DRIVE_SERVICE_ACCOUNT_JSON` debe estar configurada

3. **ID de carpeta antigua**: `1FIqYgvRuNXLJxA52LcRNCW_H1FuZ14sD`

## Paso 1: DRY RUN (Recomendado primero)

Para ver qué se va a migrar sin hacer cambios:

```bash
rails google_drive:dry_run[1FIqYgvRuNXLJxA52LcRNCW_H1FuZ14sD]
```

Esto mostrará:
- Cuántos archivos se migrarían
- Cuántos documentos en BD se actualizarían por cada archivo
- NO hace ningún cambio real

## Paso 2: Ejecutar Migración Real

**IMPORTANTE**: Esto copiará archivos y actualizará la BD. Asegúrate del backup.

```bash
rails google_drive:migrate[1FIqYgvRuNXLJxA52LcRNCW_H1FuZ14sD]
```

El comando:
1. Te pedirá confirmación (escribe 's' y Enter)
2. Copiará cada archivo de la carpeta antigua a la nueva
3. Actualizará automáticamente los `google_file_id` en la BD
4. Compartirá públicamente cada archivo nuevo
5. Mostrará un resumen final

## Qué hace el proceso

Para cada archivo:
1. **Copia directamente** en Google Drive (sin descargar/subir, muy rápido)
2. **Obtiene el nuevo file_id**
3. **Comparte públicamente** el archivo nuevo
4. **Busca en BD**: `Document.where(google_file_id: file_id_antiguo)`
5. **Actualiza automáticamente**: `document.update(google_file_id: file_id_nuevo)`
6. **Mantiene todos los demás campos** (content_type, folder_id, name, etc.)

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

