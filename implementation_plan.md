# Plan: Optimización Funcional y de Interfaz (feat/ui-search-edit) - [COMPLETADO]

## Objetivo
Mejorar la experiencia del auditor con búsqueda de ventas, edición de comandas registradas, y mejoras de ergonomía visual en íconos críticos.

---

## Módulo 1: Búsqueda de Ventas (Completado)
- Barra de búsqueda global en `ReportsScreen` accesible mediante el ícono 🔍.
- Permite buscar por número de comanda o por fecha (ej: "29/03").
- Texto ajustado a alto contraste (negro/azul sobre fondo claro).

---

## Módulo 2: Edición de Comandas Existentes (Completado)
- Pantalla completa `SaleEditScreen` permite:
    - **Modificar Cantidad**: mediante botones `+/-`.
    - **Modificar Nombre**: mediante `TextField` dedicado por cada ítem.
    - **Borrar Ítem**: mediante ícono de basura.
- El total se recalcula automáticamente y se persiste en la BD al pulsar "GUARDAR CAMBIOS".

---

## Módulo 3: Mejoras de UI (Completado)
- Íconos de AppBar aumentados a `28-30px`.
- Ícono de selección (`checklist_rtl`) y recibo (`receipt_long`) mejorados en tamaño.
- El texto del buscador ahora es perfectamente visible (contraste corregido).

---

## Verificación Final
- [x] Búsqueda por N° comanda → Resultados inmediatos.
- [x] Edición de nombre y cantidad → Total recalculado y persistido.
- [x] Visibilidad del buscador → Texto oscuro sobre fondo blanco corregido.
- [x] Usabilidad → Íconos fáciles de presionar en móviles.
