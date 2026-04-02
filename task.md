# Tareas: Optimización de Búsqueda (feat/ui-search-edit)

## Módulo 1: Refinamiento de la consulta SQL
- [ ] `db_helper.dart` — Actualizar `searchSales(String query)`:
    - Asegurar que el query se aplique **exclusivamente** a `ticket_number` y `date`.
    - Implementar un reformateador de fecha simple (ej: pasar de `dd/mm` a `YYYY-MM-DD`).
    - Eliminar cualquier otra propiedad que se estuviera comparando (actualmente ya está solo con esas dos, pero se debe reforzar).

## Módulo 2: Interfaz de Usuario (UI)
- [ ] `reports_screen.dart` — Ajustar el `hintText` para que sea más claro.
- [ ] `reports_screen.dart` — Validar que el query se pase correctamente al `DatabaseHelper`.

## Verificación Final
- [ ] Buscar un monto exacto (ej: `7500`) → Debe dar resultado vacío.
- [ ] Buscar un número de comanda parcial (ej: `2`) → Debe encontrar las correctas.
- [ ] Buscar una fecha en formato `dd/mm` o `yyyy-mm` → Debe encontrar las correctas.
