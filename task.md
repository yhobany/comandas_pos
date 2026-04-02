# Tareas: feat/ui-search-edit - [COMPLETADO]

## Módulo 1: Búsqueda de Ventas en Reportes
- [x] `db_helper.dart` — Añadir `searchSales(String query)`
- [x] `reports_screen.dart` — Añadir campo de búsqueda expandible
- [x] `reports_screen.dart` — Texto con alto contraste corregido ✅
- [x] `reports_screen.dart` — Mostrar resultados de búsqueda global
- [x] `reports_screen.dart` — Al limpiar búsqueda, volver al filtro de fecha activo

## Módulo 2: Edición de Ventas Existentes
- [x] `db_helper.dart` — Añadir `updateSaleItem(SaleItem item)`
- [x] `db_helper.dart` — Añadir `deleteSaleItem(int itemId)`
- [x] `db_helper.dart` — Añadir `updateSaleTotalAmount(int saleId, double newTotal)`
- [x] `lib/screens/sale_edit_screen.dart` — **Modificado para incluir edición de nombre** ✅
- [x] `reports_screen.dart` — Al tocar una venta, navegar a `SaleEditScreen`
- [x] `sale_edit_screen.dart` — Guardar cambios de nombre y cantidad, y refrescar reporte ✅

## Módulo 3: Mejoras Visuales de Íconos
- [x] `reports_screen.dart` — Aumentar tamaño de íconos en AppBar (trash + checklist)
- [x] `reports_screen.dart` — Mejorar visibilidad del checkbox en modo selección
- [x] `reports_screen.dart` — Aumentar tamaño del recibo (`receipt_long: 30`) ✅
- [x] `product_list_screen.dart` — Aumentar tamaño del ícono de eliminar (28)

## Verificación Final
- [x] Prueba de búsqueda por número de comanda (legibilidad perfecta) ✅
- [x] Prueba de edición: cambiar nombre y cantidad → Total recalcula y persiste ✅
- [x] Prueba de borrar ítem individual → Venta sigue visible con total correcto ✅
- [x] Verificación visual: íconos claramente visibles en toda la app ✅
