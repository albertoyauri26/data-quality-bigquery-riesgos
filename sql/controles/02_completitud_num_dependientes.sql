-- Control:   completitud_num_dependientes
-- Dimensión: Completitud
-- Regla:     todo cliente debe tener registrado su número de dependientes (puede ser 0, no nulo).
-- Umbral:    se tolera hasta 5 % de nulos; por encima, ALERTA.
-- Por qué importa en Riesgos: los dependientes reducen el ingreso disponible y se usan
--   en la evaluación socioeconómica. Un nulo no es lo mismo que 0: tratarlo como 0
--   subestima la carga familiar del cliente.
SELECT
  'completitud_num_dependientes' AS nombre_control,
  'Completitud' AS dimension,
  'num_dependientes' AS campo,
  5.0 AS umbral,
  id_cliente,
  CAST(num_dependientes AS STRING) AS valor,
  TRUE AS evaluado,
  num_dependientes IS NULL AS fallido
FROM `riesgos_dq.clientes_credito`
