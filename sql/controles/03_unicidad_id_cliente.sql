-- Control:   unicidad_id_cliente
-- Dimensión: Unicidad
-- Regla:     cada id_cliente debe aparecer una sola vez y nunca ser nulo.
-- Umbral:    0 % (ningún duplicado es aceptable).
-- Por qué importa en Riesgos: un cliente duplicado se cuenta dos veces en la cartera,
--   infla la exposición y distorsiona indicadores como la tasa de mora o las provisiones.
--   Suele aparecer cuando una carga se ejecuta dos veces.
SELECT
  'unicidad_id_cliente' AS nombre_control,
  'Unicidad' AS dimension,
  'id_cliente' AS campo,
  0.0 AS umbral,
  id_cliente,
  CAST(id_cliente AS STRING) AS valor,
  TRUE AS evaluado,
  -- COUNT(*) OVER cuenta cuántas filas comparten el mismo id sin agrupar la tabla
  id_cliente IS NULL OR COUNT(*) OVER (PARTITION BY id_cliente) > 1 AS fallido
FROM `riesgos_dq.clientes_credito`
