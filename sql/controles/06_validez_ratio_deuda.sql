-- Control:   validez_ratio_deuda
-- Dimensión: Validez
-- Regla:     ratio_deuda (pagos de deuda / ingreso) debe estar entre 0 y 5.
--            Lo normal es 0-1 (0 % a 100 % del ingreso); se acepta hasta 5 como margen
--            para casos extremos reales. Por encima, el valor ya no es un ratio sino un error.
-- Umbral:    se tolera hasta 1 % de registros fuera de rango.
-- Por qué importa en Riesgos: es la medida principal de sobreendeudamiento. Un ratio de
--   miles suele significar que se dividió entre un ingreso faltante o casi cero, y engaña
--   a cualquier regla de aprobación o modelo que lo use.
SELECT
  'validez_ratio_deuda' AS nombre_control,
  'Validez' AS dimension,
  'ratio_deuda' AS campo,
  1.0 AS umbral,
  id_cliente,
  CAST(ratio_deuda AS STRING) AS valor,
  ratio_deuda IS NOT NULL AS evaluado,
  ratio_deuda < 0 OR ratio_deuda > 5 AS fallido
FROM `riesgos_dq.clientes_credito`
