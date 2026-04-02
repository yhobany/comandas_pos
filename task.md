# Tareas Activas: Borrado Selectivo de Ventas

## Completadas ✅
- [x] Creación correcta de productos desde OCR (id null → addProduct)
- [x] Vinculación en tiempo real del SaleItem al nuevo producto
- [x] Filtro OCR restaurado al 70%
- [x] Selector de fecha editable en pantalla de Validación
- [x] Navegación `< Día >` en Reportes para cierres históricos
- [x] Buscador en Menú & Precios (nombre o categoría)
- [x] Corrección del formato de fecha en ValidationScreen

## Completado: Borrado Selectivo de Ventas
- [x] Añadir método `deleteSaleById(int id)` en `DatabaseHelper`
- [x] Añadir estado `_selectionMode` y `Set<int> _selectedIds` en `ReportsScreen`
- [x] Modificar el AppBar para mostrar el conteo de seleccionados y botón de cancelar
- [x] Convertir cada `ListTile` en un `CheckboxListTile` cuando `_selectionMode == true`
- [x] Añadir botón de "Eliminar selección" con confirmación
- [x] Refrescar el listado y el total al eliminar
