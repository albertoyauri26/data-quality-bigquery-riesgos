-- Análisis de causa raíz de los hallazgos. Se ejecuta a demanda; no forma parte de los controles diarios.
-- Una sola pasada sobre la tabla (≈10 MB) en vez de una consulta por pregunta.
SELECT
  COUNT(*) AS total_clientes,
  ROUND(100 * AVG(mora_grave_2_anios), 2) AS tasa_mora_general_pct,

  -- 1) ¿Los nulos de ingreso son aleatorios? Si la mora cambia según el ingreso esté o no, el nulo "informa" algo.
  ROUND(100 * AVG(IF(ingreso_mensual IS NULL, mora_grave_2_anios, NULL)), 2) AS tasa_mora_ingreso_nulo_pct,
  ROUND(100 * AVG(IF(ingreso_mensual IS NOT NULL, mora_grave_2_anios, NULL)), 2) AS tasa_mora_ingreso_informado_pct,

  -- 2) ¿De dónde salen los ratio_deuda fuera de rango (> 5)?
  COUNTIF(ratio_deuda > 5) AS ratio_deuda_fuera_rango,
  COUNTIF(ratio_deuda > 5 AND ingreso_mensual IS NULL) AS fuera_rango_con_ingreso_nulo,
  COUNTIF(ratio_deuda > 5 AND ingreso_mensual BETWEEN 0 AND 1) AS fuera_rango_con_ingreso_0_o_1,
  APPROX_QUANTILES(IF(ingreso_mensual IS NULL, ratio_deuda, NULL), 2)[OFFSET(1)] AS mediana_ratio_deuda_ingreso_nulo,
  APPROX_QUANTILES(IF(ingreso_mensual IS NOT NULL, ratio_deuda, NULL), 2)[OFFSET(1)] AS mediana_ratio_deuda_ingreso_informado,

  -- 3) Los códigos 96/98: ¿son ruido o esconden información de riesgo?
  COUNTIF(num_atrasos_90_dias IN (96, 98)) AS filas_codigo_96_98,
  ROUND(100 * AVG(IF(num_atrasos_90_dias IN (96, 98), mora_grave_2_anios, NULL)), 2) AS tasa_mora_codigo_96_98_pct,

  -- 4) ¿Los dependientes nulos son un subconjunto de los ingresos nulos? (sugiere una misma causa en el origen)
  COUNTIF(num_dependientes IS NULL) AS dependientes_nulos,
  COUNTIF(num_dependientes IS NULL AND ingreso_mensual IS NULL) AS dependientes_e_ingreso_nulos,

  -- 5) Edades inválidas y otros valores sospechosos que aún no tienen control
  COUNTIF(edad < 18) AS edad_menor_18,
  COUNTIF(edad > 100) AS edad_mayor_100,
  COUNTIF(ingreso_mensual = 0) AS ingreso_cero,
  COUNTIF(ratio_uso_lineas_rotativas > 1) AS uso_lineas_mayor_100pct,
  COUNTIF(ratio_uso_lineas_rotativas > 10) AS uso_lineas_mayor_1000pct
FROM `riesgos_dq.clientes_credito`;
