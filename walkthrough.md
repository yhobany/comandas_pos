# Walkthrough: feat/ui-search-edit - [COMPLETADO]

## 1. Búsqueda de Ventas en Reportes 🔍 (Mejorada)
- **Activación**: Mediante el nuevo ícono `🔍` en el AppBar de Reportes.
- **Búsqueda Global**: Encuentra por número de comanda o por fecha (ej: "29/03") en toda la base de datos.
- **Visibilidad Corregida**: Se ajustó el color del texto a **negro (`black87`)** con cursor azul para asegurar legibilidad perfecta sobre el fondo blanco del buscador.

## 2. Edición de Comandas Existentes ✏️
Al tocar cualquier comanda en el listado, se abre la nueva pantalla **`SaleEditScreen`**.

**Nuevas Funcionalidades:**
- **Edición de Nombre**: Cada producto tiene un campo de texto dedicado para corregir posibles fallos de lectura del OCR puntual.
- **Edición de Cantidad**: Controles `+` y `-` (ahora en color naranja/verde vibrante).
- **Eliminación**: Botón `🗑️` para borrar ese producto específico de la venta.
- **Recálculo Automático**: El total se actualiza al instante en el banner superior (azul para guardado, naranja para cambios pendientes).
- **Persistencia**: El botón "GUARDAR CAMBIOS" guarda nombres, cantidades y el nuevo total en la base de datos.

## 3. Mejoras de UI (Usabilidad Táctil) 📏
- **Íconos más grandes**:
    - AppBar (trash, checklist, search): `size: 28`.
    - Modo selección (`receipt_long`): `size: 30`.
    - Ícono eliminar en "Menú & Precios": `size: 28`.
- **Contraste**: Los botones y textos de edición se ajustaron para mejorar la visibilidad bajo cualquier iluminación.

## Archivos Finalizados
- `lib/services/db_helper.dart` — Métodos: `searchSales`, `updateSaleItem`, `deleteSaleItem`, `updateSaleTotalAmount`
- `lib/screens/reports_screen.dart` — Buscador con contraste corregido e íconos grandes.
- `lib/screens/sale_edit_screen.dart` — Nueva UI de edición con nombres editables.
- `lib/screens/product_list_screen.dart` — Íconos aumentados.
