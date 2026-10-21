-- GENERADO por scripts/desplegar.py a partir de sql/controles/*.sql. No editar a mano.
-- Consulta maestra: ejecuta todos los controles y agrega una fila por control a resultados_controles.
-- Está dentro de un procedimiento para que la Scheduled Query solo tenga que hacer CALL.
CREATE OR REPLACE PROCEDURE `riesgos_dq.sp_ejecutar_controles`()
BEGIN
  INSERT INTO `riesgos_dq.resultados_controles`
    (fecha_ejecucion, nombre_control, dimension, campo, registros_evaluados, registros_fallidos, pct_error, umbral, estado)
  WITH controles AS (
    -- 01_completitud_ingreso_mensual.sql
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
    UNION ALL
    -- 02_completitud_num_dependientes.sql
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
    UNION ALL
    -- 03_unicidad_id_cliente.sql
    SELECT
      'unicidad_id_cliente' AS nombre_control,
      'Unicidad' AS dimension,
      'id_cliente' AS campo,
      0.0 AS umbral,
      id_cliente,
      CAST(id_cliente AS STRING) AS valor,
      TRUE AS evaluado,
      id_cliente IS NULL OR COUNT(*) OVER (PARTITION BY id_cliente) > 1 AS fallido
    FROM `riesgos_dq.clientes_credito`
    UNION ALL
    -- 04_validez_edad.sql
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
    UNION ALL
    -- 05_validez_ingreso_mensual.sql
    SELECT
      'validez_ingreso_mensual' AS nombre_control,
      'Validez' AS dimension,
      'ingreso_mensual' AS campo,
      0.0 AS umbral,
      id_cliente,
      CAST(ingreso_mensual AS STRING) AS valor,
      ingreso_mensual IS NOT NULL AS evaluado,
      ingreso_mensual < 0 AS fallido
    FROM `riesgos_dq.clientes_credito`
    UNION ALL
    -- 06_validez_ratio_deuda.sql
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
    UNION ALL
    -- 07_validez_atrasos_30_59_dias.sql
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
    UNION ALL
    -- 08_validez_atrasos_60_89_dias.sql
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
    UNION ALL
    -- 09_validez_atrasos_90_dias.sql
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
    UNION ALL
    -- 10_consistencia_atrasos_90_vs_30_59.sql
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
  ),
  resumen AS (
    SELECT
      nombre_control, dimension, campo, umbral,
      COUNTIF(evaluado) AS registros_evaluados,
      COUNTIF(evaluado AND fallido) AS registros_fallidos
    FROM controles
    GROUP BY nombre_control, dimension, campo, umbral
  ),
  con_pct AS (
    SELECT *, 100 * SAFE_DIVIDE(registros_fallidos, registros_evaluados) AS pct_error
    FROM resumen
  )
  SELECT
    CURRENT_TIMESTAMP(),
    nombre_control, dimension, campo, registros_evaluados, registros_fallidos, pct_error, umbral,
    -- Un control que no evaluó ningún registro también es ALERTA: no podemos afirmar que los datos estén bien
    IF(registros_evaluados = 0 OR pct_error > umbral, 'ALERTA', 'OK')
  FROM con_pct;
END;
