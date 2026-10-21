-- Control:   validez_atrasos_90_dias
-- Dimensión: Validez
-- Regla:     el número de atrasos de 90+ días debe estar entre 0 y 24. El diccionario no indica
--            ventana de tiempo, así que usamos el mismo límite que en las otras columnas de atraso:
--            los 96/98 aparecen idénticos en las tres columnas de las mismas filas, lo que
--            confirma que son códigos y no conteos.
-- Umbral:    0 %.
-- Por qué importa en Riesgos: 90+ días es la definición regulatoria de default. Un código
--   96/98 leído como número convierte a un cliente en "defaulter" serial y puede disparar
--   provisiones o rechazos que no corresponden.
SELECT
  'validez_atrasos_90_dias' AS nombre_control,
  'Validez' AS dimension,
  'num_atrasos_90_dias' AS campo,
  0.0 AS umbral,
  id_cliente,
  CAST(num_atrasos_90_dias AS STRING) AS valor,
  num_atrasos_90_dias IS NOT NULL AS evaluado,
  num_atrasos_90_dias NOT BETWEEN 0 AND 24 AS fallido
FROM `riesgos_dq.clientes_credito`
