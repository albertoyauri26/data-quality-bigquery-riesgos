-- Control:   validez_atrasos_60_89_dias
-- Dimensión: Validez
-- Regla:     el número de atrasos de 60-89 días en 24 meses debe estar entre 0 y 24.
-- Umbral:    0 %.
-- Por qué importa en Riesgos: mismo riesgo que en 30-59 días. Los códigos 96/98 se leerían
--   como decenas de atrasos y el modelo trataría al cliente como un moroso extremo.
SELECT
  'validez_atrasos_60_89_dias' AS nombre_control,
  'Validez' AS dimension,
  'num_atrasos_60_89_dias' AS campo,
  0.0 AS umbral,
  id_cliente,
  CAST(num_atrasos_60_89_dias AS STRING) AS valor,
  num_atrasos_60_89_dias IS NOT NULL AS evaluado,
  num_atrasos_60_89_dias NOT BETWEEN 0 AND 24 AS fallido
FROM `riesgos_dq.clientes_credito`
