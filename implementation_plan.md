# Plan: Optimización de Búsqueda de Ventas (feat/ui-search-edit)

## Objetivo
Refinar la función de búsqueda en `ReportsScreen` para que sea **estrictamente exclusiva** a los campos de *Número de Comanda* y *Fecha*, ignorando cualquier otro atributo (como montos o IDs internos), y mejorando la consistencia en el formato de búsqueda de fechas.

---

## Módulo 1: Refinamiento de la consulta SQL

### Problema
La consulta actual utiliza `LIKE` simple sobre `ticket_number` y `date`. Si el usuario ingresa una fecha en formato común (ej: `01/04`), la coincidencia con el formato ISO8601 de la base de datos (`2026-04-01...`) es inconsistente o inexistente.

### Solución Propuesta

#### [MODIFY] `lib/services/db_helper.dart`
- Actualizar `searchSales(String query)`:
    - Si el query contiene `/` o `-`, intentar reformatearlo para que coincida con partes del formato ISO `YYYY-MM-DD`.
    - Mantener la exclusividad del `WHERE` solo para `ticket_number` y `date`.
    - Asegurar que no se realicen búsquedas accidentales en `total_amount` o `id`.

---

## Módulo 2: Interfaz de Usuario (UI)

#### [MODIFY] `lib/screens/reports_screen.dart`
- Asegurar que la lógica de `onChanged` procese el query de forma que la base de datos reciba los términos más limpios posibles.
- Mantener el contraste del texto ya corregido.

---

## Open Questions

> [!IMPORTANT]
> **Sobre el formato de fecha:** Cuando buscas por fecha, ¿prefieres que sea una coincidencia parcial (ej: escribir `04` y que salgan todas las de abril) o que intentemos forzar el formato `dd/mm/yyyy`? He optado por mantener la flexibilidad de búsqueda parcial por su rapidez.

## Verification Plan
1. Ingresar un monto de venta (ej: `7500`) en el buscador → El resultado debe ser vacío (confirmando que ignora otros campos).
2. Ingresar un número de comanda parcial (ej: `2`) → Debe mostrar las comandas `2`, `22`, etc.
3. Ingresar una fecha en formato `dd/mm` (ej: `01/04`) → Debe mostrar las ventas del 1 de abril.
