-- Vistas para Looker Studio. Una vista no guarda datos: es una consulta con nombre que se
-- ejecuta cada vez que alguien la lee. El dashboard queda simple y la lógica, en SQL versionado.

-- 1) Estado actual: el último resultado de cada control (semáforo).
--    Todos los controles se insertan en una sola sentencia, así que comparten la misma fecha_ejecucion.
CREATE OR REPLACE VIEW `riesgos_dq.v_estado_actual` AS
SELECT
  fecha_ejecucion,
  nombre_control,
  dimension,
  campo,
  registros_evaluados,
  registros_fallidos,
  pct_error,
  umbral,
  estado,
  IF(estado = 'OK', '🟢 OK', '🔴 ALERTA') AS semaforo
FROM `riesgos_dq.resultados_controles`
WHERE fecha_ejecucion = (SELECT MAX(fecha_ejecucion) FROM `riesgos_dq.resultados_controles`);

-- 2) % de error por campo en la última ejecución (un campo puede tener varios controles).
CREATE OR REPLACE VIEW `riesgos_dq.v_error_por_campo` AS
SELECT
  campo,
  COUNT(*) AS controles,
  COUNTIF(estado = 'ALERTA') AS controles_en_alerta,
  SUM(registros_fallidos) AS registros_fallidos,
  MAX(pct_error) AS pct_error_max
FROM `riesgos_dq.v_estado_actual`
GROUP BY campo;

-- 3) Evolución diaria: si un día hubo varias ejecuciones, se queda con la última.
CREATE OR REPLACE VIEW `riesgos_dq.v_evolucion` AS
SELECT
  DATE(fecha_ejecucion) AS fecha,
  nombre_control,
  dimension,
  campo,
  pct_error,
  umbral,
  estado
FROM `riesgos_dq.resultados_controles`
QUALIFY ROW_NUMBER() OVER (PARTITION BY nombre_control, DATE(fecha_ejecucion) ORDER BY fecha_ejecucion DESC) = 1;
