-- Control:   consistencia_atrasos_90_vs_30_59
-- Dimensión: Consistencia
-- Regla:     un cliente no debería tener más atrasos de 90+ días que de 30-59 días, porque
--            para llegar a 90 días de mora primero hay que pasar por 30-59.
-- Umbral:    se tolera hasta 5 %. Es una regla de PLAUSIBILIDAD, no de imposibilidad:
--            la columna 30-59 cuenta atrasos "que no empeoraron", así que un atraso que
--            escaló a 90+ no suma en 30-59. Por eso existen casos legítimos y se tolera un margen.
-- Por qué importa en Riesgos: si el porcentaje es alto, los campos de atraso se están
--   calculando con criterios distintos (fechas de corte, sistemas diferentes) y no se pueden
--   comparar entre sí para construir el historial de mora del cliente.
-- Solo se evalúan registros con ambos campos válidos; los códigos 96/98 ya los reportan
-- los controles de validez y no se cuentan dos veces.
SELECT
  'consistencia_atrasos_90_vs_30_59' AS nombre_control,
  'Consistencia' AS dimension,
  'num_atrasos_90_dias vs num_atrasos_30_59_dias' AS campo,
  5.0 AS umbral,
  id_cliente,
  FORMAT('90+: %d | 30-59: %d', num_atrasos_90_dias, num_atrasos_30_59_dias) AS valor,
  num_atrasos_90_dias BETWEEN 0 AND 24 AND num_atrasos_30_59_dias BETWEEN 0 AND 24 AS evaluado,
  num_atrasos_90_dias > num_atrasos_30_59_dias AS fallido
FROM `riesgos_dq.clientes_credito`
