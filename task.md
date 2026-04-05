# Tareas: Exportación de Comandas a PDF

## Módulo 1: Dependencias
- [x] Ejecutar `flutter pub add pdf printing`.
- [x] Asegurar que el proyecto compila tras las nuevas librerías.

## Módulo 2: Servicio PDF (`lib/services/pdf_service.dart`)
- [x] Crear clase `PdfService`.
- [x] Construir la maquetación del PDF usando paquete `pdf/widgets.dart`
    - [x] Titular y Fecha del reporte.
    - [x] Ciclo por cada venta: Encabezado (N° comanda y Fecha), Tabla con productos, total de la venta.
    - [x] Suma total (Consolidado final).
- [x] Consumir `DatabaseHelper` para rellenar los `SaleItem`.
- [x] Usar `Printing.sharePdf(...)` para compartir.

## Módulo 3: Interfaz UI (`lib/screens/reports_screen.dart`)
- [x] Añadir botón de "Exportar a PDF" en el bloque de acciones de selección.
- [x] Conectar el estado actual (`_selectedIds`, `_sales`) con la función del servicio.
- [x] Mostrar un identificador de carga temporal (opcional) si es muy masiva la selección.

## Verificación Final
- [x] Entrar al modo selección de comandas en la app.
- [x] Seleccionar 2 reportes válidos, oprimir Exportar.
- [x] Comprobar apertura del menú del sistema y apertura del PDF renderizado.
