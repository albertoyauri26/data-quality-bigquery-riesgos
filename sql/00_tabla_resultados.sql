-- Tabla histórica de resultados: una fila por control y por ejecución.
-- Particionada por día: las consultas que filtran por fecha solo leen los días que necesitan (menos costo).
-- IF NOT EXISTS: volver a desplegar no borra el historial.
CREATE TABLE IF NOT EXISTS `riesgos_dq.resultados_controles` (
  fecha_ejecucion     TIMESTAMP NOT NULL OPTIONS(description = 'Momento en que se ejecutaron los controles (UTC)'),
  nombre_control      STRING    NOT NULL OPTIONS(description = 'Identificador del control, igual al nombre de su archivo .sql'),
  dimension           STRING    OPTIONS(description = 'Dimensión de calidad: Completitud, Unicidad, Validez o Consistencia'),
  campo               STRING    OPTIONS(description = 'Campo(s) de clientes_credito evaluados'),
  registros_evaluados INT64     OPTIONS(description = 'Registros a los que aplica la regla'),
  registros_fallidos  INT64     OPTIONS(description = 'Registros que incumplen la regla'),
  pct_error           FLOAT64   OPTIONS(description = 'registros_fallidos / registros_evaluados * 100'),
  umbral              FLOAT64   OPTIONS(description = '% de error máximo tolerado'),
  estado              STRING    OPTIONS(description = 'OK si pct_error <= umbral; si no, ALERTA')
)
PARTITION BY DATE(fecha_ejecucion)
OPTIONS(description = 'Resultados históricos de los controles de calidad de datos de riesgos');
