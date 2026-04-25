# Walkthrough: Edición Manual y Reportes Multiformato

Se han implementado mejoras significativas en la flexibilidad del sistema de comandas, permitiendo la intervención manual total, el soporte desde cero, y la exportación de reportes en formatos PDF y Excel.

## 1. Nueva Creación Totalmente Manual
Ahora es posible omitir por completo el flujo de captura de la cámara si solo necesitas ingresar una comanda en blanco:
- **Pantalla Inicial (Scanner)**: Se ha agregado un botón secundario llamado **"Crear Comanda Manualmente"** que te redirige a una comanda limpia.
- **Pantalla de Validación**: Si omites la cámara, verás un estado vacío claro que te invita a usar el botón **"Añadir Producto Manualmente"**.

## 2. Edición Manual de Comandas
Se han habilitado nuevos puntos de entrada para la edición manual, cubriendo todos los casos de uso:
- **Historial de Ventas**: Al ver una venta guardada, ahora puedes añadir nuevos ítems usando el botón **"+"** en la parte superior derecha.
- **Botones Adaptables**: Se ha corregido un pequeño error de desbordamiento de la interfaz (overflow) al editar ítems. Ahora, los botones de (+ / - / eliminar) se adaptan inteligentemente al ancho de cualquier pantalla sin generar errores visuales.
- **Edición Directa**: Los nombres de los productos parciales pueden editarse haciendo tap sobre ellos.

## 3. Reportes Multiformato (PDF / XLSX)
La funcionalidad de exportación se unificó bajo un único menú de opciones:
- Selecciona varias comandas en la pantalla de Reportes.
- El botón de "Compartir" desplegará un menú inferior (Bottom Sheet).
- Elige **Excel (XLSX)** para un archivo tabulado o **PDF** para un documento imprimible. El formato Excel imita la jerarquía original separando cada venta por su cabecera y listando luego sus ítems, seguido de la sumatoria total final.

## 4. Servicios Técnicos Clave
- Se implementó `XlsxService` usando la librería compilable `excel` v4.
- Uso de `share_plus` garantizado para exportaciones nativas transparentes hacia WhatsApp/Mail.
