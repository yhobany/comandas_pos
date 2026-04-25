# Lineamientos de Diseño UI/UX - Comandas OCR

Este documento establece las buenas prácticas, convenciones y patrones de diseño aplicados en la aplicación para asegurar consistencia, escalabilidad y una experiencia de usuario (UX) profesional en futuras iteraciones.

---

## 1. Consistencia Visual y Temática

### 1.1 Esquema de Color
- **Color Primario:** Azul (`Colors.blue` a `Colors.blue.shade800`). Utilizado en AppBars, FloatingActionButtons y botones de acciones principales (ej. escaneo).
- **Colores Secundarios/Acentos:** Tonos verdes (`Colors.green`) para confirmaciones, totales o ganancias; y rojo/naranja (`Colors.red`, `Colors.orange`) para eliminaciones o advertencias.
- **Fondos:** Se priorizan los fondos claros o blancos para mantener el contraste.

### 1.2 Formas y Botones
- **Homogeneidad:** Todos los controles de un mismo flujo deben compartir el diseño. Se prefiere evitar una mezcla agresiva de recuadros afilados, prefiriendo siempre bordes redondeados (`borderRadius: BorderRadius.circular(10)` o `12`).
- **Botones de Inicio:** Utilizan `StadiumBorder()` (píldoras) con anchos unificados (usando `SizedBox` en Columnas) para crear bloques visuales atractivos.
- **Elevación:** Uso sutil de sombras. En botones o tarjetas (`Card`), una elevación baja (`elevation: 1` o `2`) separa limpiamente el contenido del fondo sin ensuciar la interfaz.

---

## 2. Manejo de Layouts y Prevención de Desbordamiento (Overflow)

### 2.1 Principios de Flexibilidad
Nunca se debe depender de alturas o anchuras absolutas y rígidas para los flujos de contenido dinámico.
- **Textos en Fila (`Row`):** Cualquier texto propenso a ser largo (ej. nombres de productos, títulos en `AlertDialog`) debe envolverse de manera segura dentro de un widget expansible:
  ```dart
  Expanded(child: Text('Titulo o Nombre Dinámico', overflow: TextOverflow.visible))
  ```
- **Controles Laterales (Acciones):** Si hay conjuntos de interacciones (botones de +, -, eliminar) uno detrás de otro, es altamente recomendado utilizar el widget `Wrap` en vez de un `Row` con `MainAxisSize.max`. De esta forma, si falta espacio, el bloque baja a la siguiente línea armoniosamente en vez de generar un error rojo de desbordamiento horizontal en pantallas pequeñas.

---

## 3. Navegación y Flujos de Tareas

### 3.1 Rutas Alternativas
- **No forzar caminos únicos (Dead-ends):** El flujo original era 100% dependiente de la cámara OCR. Basado en el diseño óptimo actual, siempre se debe entregar al usuario un "Flujo Manual de Rescate". 
- Se instaló un bloque claro de "Crear Comanda Manualmente". Futuras integraciones (ej. búsqueda web, importación de galería) deben seguir este método de "Atajos (Bypass)".

### 3.2 Feedback Visual Activo
El usuario jamás debe adivinar el resultado de su acción ni interpretar vacíos en la interfaz.
- **Empty States (Estados Vacíos):** Al cargar una lista (ej. Menú de Productos, Validación sin OCR) donde no hay ítems reales, NUNCA dejar un lienzo en blanco o un simple texto. Replicar el modelo de icono flotante central + texto en gris + CTA (Call to Action / Botón principal) recomendando la siguiente acción explícita.
- **Snackbars:** Uso de notificaciones efímeras inferiores confirmando acciones no reversibles (guardar, actualizar) usando `backgroundColor: Colors.green` o advertir errores o detenciones usando colores temáticos como anaranjado y rojo.

---

## 4. Recomendaciones para el Futuro

### 4.1 Reutilización de Componentes (Modularidad)
- **Extracción al directorio `widgets/`:** Actualmente muchas pantallas engloban sus tarjetas de listas y diálogos localmente (`_showAddDialog()`). Si se planea agregar más pantallas que gestionen ítems manuales, extraer este componente (`SaleItemCard`) a un archivo propio simplificará el código maestro.
- **Unificación Tipográfica:** Definir estilos fijos en el parámetro genérico `textTheme` del `MaterialApp` principal en base a los utilizados actualmente, evitando definir `TextStyle(fontSize: 16)` manualmente en cada nodo de la aplicación.

### 4.2 Accesibilidad y Legibilidad
- Considerar siempre fuentes legibles como la actual predeterminada de Material.
- Asegurar que los botones mantienen `Padding` interno cómodo (`symmetric(horizontal: 20, vertical: 12)`) facilitando la pulsación ('tap') para el perfil promedio, previniendo los *clicks erróneos* de la llamada 'grasa dactilar' (Fat-finger errors).
