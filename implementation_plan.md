# Plan: Exportación de Comandas a PDF

## Contexto y Objetivo
El usuario requiere generar un reporte consolidado en formato PDF a partir de una selección manual y múltiple de comandas en la pantalla de reportes. El PDF debe incluir métricas individuales (ítems y totales) y un consolidado general, utilizando la lógica de cajas de selección (`checkboxes`) pre-existente sin afectar el flujo de eliminación.

## User Review Required

> [!IMPORTANT]
> **Adición de Dependencias:** Para la generación de PDF nativa en el dispositivo y la opción de compartirlo (WhatsApp, Guardar en Files, Imprimir), instalaré los paquetes oficiales `pdf` y `printing`. ¿Estás de acuerdo con añadir estas librerías?
> **Estructura del Proyecto:** Propondré crear un archivo específico `lib/services/pdf_service.dart` para no saturar la pantalla de UI con la pesada maquetación del documento PDF.

## Proposed Changes

### Dependencias
#### [MODIFY] `pubspec.yaml`
- Añadir las librerías `pdf: ^3.10.8` y `printing: ^5.11.1`.

### Servicios
#### [NEW] `lib/services/pdf_service.dart`
- Crear la clase `PdfService` con el método estático `generateAndShareSalesPdf(List<Sale> sales)`.
- El método realizará consultas a la base de datos (con `DatabaseHelper.instance.getSaleItemsBySaleId`) para extraer los productos de todas las ventas suministradas.
- Construirá el documento PDF estructurado como estipula el requerimiento (Número de comanda, fecha, productos, cantidades, subtotales, total de comanda y un Total General consolidado).
- Integrará `Printing.sharePdf(bytes: await pdf.save(), filename: 'Reporte_Ventas.pdf')` para abrir el menú del sistema.

### UI
#### [MODIFY] `lib/screens/reports_screen.dart`
- Adaptar la barra superior (AppBar) para mostrar dos opciones cuando entremos en **modo de selección** (`_selectionMode = true`) con dependencias:
    1. 🗑️ Botón Eliminar (Color Rojo) - Funcionalidad intocada.
    2. 📄 Botón Exportar PDF (Color Azul) - Nueva funcionalidad.
- Al pulsar Exportar PDF:
    - Se mostrará un indicador o modal de progreso que extrae de `_sales` las comandas coincidentes con `_selectedIds`.
    - Se ejecutará `PdfService.generateAndShareSalesPdf(listaFiltrada)`.
    - Se cerrará el modo selección (opcional).

## Verificación Planificada
1. Seleccionar un rango de 2 comandas y exportar $\rightarrow$ Verificar visualmente el PDF generado.
2. Confirmar que los totales de comandas cuadren matemáticamente con el Total Consolidado en la última hoja.
3. Asegurar de que la funcionalidad antigua de "Seleccionar para borrar" sigue borrando en BD íntegramente.
