-- Control:   completitud_ingreso_mensual
-- Dimensión: Completitud
-- Regla:     todo cliente debe tener ingreso mensual registrado (no nulo).
-- Umbral:    se tolera hasta 5 % de nulos; por encima, ALERTA.
-- Por qué importa en Riesgos: sin ingreso no se puede medir la capacidad de pago
--   (cuota / ingreso) ni aplicar límites de endeudamiento. Los modelos de score
--   tendrían que imputar el dato, lo que introduce sesgo en la probabilidad de default.
SELECT
  'completitud_ingreso_mensual' AS nombre_control,
  'Completitud' AS dimension,
  'ingreso_mensual' AS campo,
  5.0 AS umbral,
  id_cliente,
  CAST(ingreso_mensual AS STRING) AS valor,
  TRUE AS evaluado,
  ingreso_mensual IS NULL AS fallido
FROM `riesgos_dq.clientes_credito`
