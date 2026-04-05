# Walkthrough: Exportación a PDF de Comandas (feat/ui-search-edit)

La nueva funcionalidad permite generar reportes profesionales listos para enviar a contadores, imprimir o guardar para auditoría.

## 1. Funcionamiento sin alterar la experiencia (UI)
Cuando ingresas en la sección `Reporte de Ventas`, el sistema cuenta con el botón de "cajas de verificación" (el botón que antes solo servía para borrar masivamente).
- Al presionarlo y seleccionar una o varias facturas de la lista, la barra de opciones se dividirá:
  - 🗑️ Un icono rojo para su eliminación permanente.
  - 📄 **Un icono azul moderno (NUEVO)** con el símbolo de PDF para exportar la selección de datos.

## 2. Generación Estructurara (PDF Service)
Al oprimir Exportar a PDF, un sistema en segundo plano tomará **exclusivamente las comandas que chequeaste**, consultará todos sus productos internos a la base de datos y armará un documento limpio.
- **Cabecera**: Contiene la fecha exacta de generación del reporte.
- **Cuerpo por cada venta**: Incluye el Número de comanda, su propia fecha de registro, y una tabla cuadriculada con el _Producto, Cantidad, Precio Unitario y Subtotal_ de lo facturado en ella. Agregando el cobro final en verde al pie.
- **Pie de Página Cierre**: Sumará los resultados de **todas** las agrupaciones seleccionadas y mostrará un recuadro enfatizado con el **Total Consolidado** general de exportación.

## 3. Compatibilidad Nativa
El servicio está equipado con la librería `printing`, de modo que al completar la conformación de tablas, Android abrirá el _Sheet_ nativo para compartir (WhatsApp, Slack, Correos) o guardar como Archivo a la memoria del equipo de inmediato, con un titulo autonumerado como `Reporte_Ventas_2026xxxx_xxxx.pdf`.

El proyecto fue re-analizado demostrando compatibilidad del 100% en sus compiladores.
