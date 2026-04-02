# Plan de Implementación: Comandas OCR — Estado Actual

## Resumen del Proyecto
Aplicación Flutter para **Auditoría Post-Venta** de restaurantes. El despachador escanea comandas físicas una a una con el OCR de la cámara, valida los ítems contra el catálogo de precios, y registra la venta en la base de datos local. Los reportes permiten hacer cierres de caja por día.

## Trabajo Completado ✅

### Rama `fix/ocr-catalog-creation`
- **Creación correcta de productos desde OCR:** Se corrigió la lógica de `ProductFormScreen._saveForm` para detectar `id == null` y usar `addProduct` en vez de `update`. El formulario se pre-llena con el texto crudo del OCR.
- **Vinculación en tiempo real:** Al crear un producto en el catálogo desde Validación, el `SaleItem` activo se actualiza con el nuevo `productId` y precio oficial.
- **Filtro OCR restaurado al 70%:** Se reactivó la censura de "basura" (nombres de meseros, horarios) para mantener la pantalla de validación limpia.
- **Selector de fecha editable en Validación:** El OCR autocompleta la fecha del ticket; el auditor puede corregirla tocando el control antes de confirmar la venta.
- **Navegación `< Día >` en Reportes:** Para el filtro "Diario", se añadieron flechas que permiten moverse entre días para realizar cierres de caja históricos.
- **Buscador en Menú & Precios:** La pantalla `ProductListScreen` cuenta con un campo de búsqueda en tiempo real por nombre y categoría.

## Tarea Pendiente (En desarrollo)

### [MODIFY] `lib/services/db_helper.dart`
- Añadir el método `deleteSaleById(int id)` para borrar una comanda individual (y sus ítems en cascada).

### [MODIFY] `lib/screens/reports_screen.dart`
- **Reemplazar** el botón de borrado total del AppBar `delete_sweep` por un botón de modo selección múltiple.
- Al activar el modo selección, cada fila de comanda muestra un `Checkbox`.
- Una barra inferior flotante (FAB o BottomSheet) aparece mostrando "X seleccionadas" y un botón de "Eliminar".
- Al confirmar, se eliminan solo las ventas seleccionadas y se refresca el reporte.

## Verification Plan
1. En Reportes, activar modo selección, marcar 2 comandas.
2. Eliminar y confirmar que solo esas 2 desaparecen.
3. Verificar que el total del reporte recalcula correctamente.
