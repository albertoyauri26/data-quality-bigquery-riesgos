-- Control:   validez_atrasos_30_59_dias
-- Dimensión: Validez
-- Regla:     el número de atrasos de 30-59 días en 24 meses debe estar entre 0 y 24
--            (como máximo un evento de mora por mes).
-- Umbral:    0 %.
-- Por qué importa en Riesgos: valores como 96 o 98 no son conteos reales; son códigos
--   especiales del sistema origen (en muchos sistemas significan "sin dato" o "no aplica")
--   guardados en una columna numérica. Si un modelo los lee como números, ve un cliente con
--   98 atrasos y distorsiona por completo su probabilidad de default.
SELECT
  'validez_atrasos_30_59_dias' AS nombre_control,
  'Validez' AS dimension,
  'num_atrasos_30_59_dias' AS campo,
  0.0 AS umbral,
  id_cliente,
  CAST(num_atrasos_30_59_dias AS STRING) AS valor,
  num_atrasos_30_59_dias IS NOT NULL AS evaluado,
  num_atrasos_30_59_dias NOT BETWEEN 0 AND 24 AS fallido
FROM `riesgos_dq.clientes_credito`
