-- Control:   validez_edad
-- Dimensión: Validez
-- Regla:     la edad debe estar entre 18 y 100 años (inclusive).
-- Umbral:    0 % (un menor de edad o una edad imposible no deberían existir).
-- Por qué importa en Riesgos: un menor no puede ser titular de un crédito (riesgo legal y
--   regulatorio) y la edad es una variable clave en los modelos de score; una edad de 0
--   o 150 delata un error de captura que contamina el modelo.
-- Los nulos no se evalúan aquí: eso le corresponde a un control de completitud.
SELECT
  'validez_edad' AS nombre_control,
  'Validez' AS dimension,
  'edad' AS campo,
  0.0 AS umbral,
  id_cliente,
  CAST(edad AS STRING) AS valor,
  edad IS NOT NULL AS evaluado,
  edad < 18 OR edad > 100 AS fallido
FROM `riesgos_dq.clientes_credito`
