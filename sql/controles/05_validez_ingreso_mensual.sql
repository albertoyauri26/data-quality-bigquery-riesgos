-- Control:   validez_ingreso_mensual
-- Dimensión: Validez
-- Regla:     el ingreso mensual no puede ser negativo.
-- Umbral:    0 %.
-- Por qué importa en Riesgos: un ingreso negativo invierte el signo del ratio cuota/ingreso
--   y haría que un cliente sobreendeudado parezca sano.
SELECT
  'validez_ingreso_mensual' AS nombre_control,
  'Validez' AS dimension,
  'ingreso_mensual' AS campo,
  0.0 AS umbral,
  id_cliente,
  CAST(ingreso_mensual AS STRING) AS valor,
  ingreso_mensual IS NOT NULL AS evaluado,
  ingreso_mensual < 0 AS fallido
FROM `riesgos_dq.clientes_credito`
