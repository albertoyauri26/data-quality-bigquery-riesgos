"""Genera la consulta maestra a partir de sql/controles/*.sql y despliega todo en BigQuery.

Crea (o actualiza): tabla resultados_controles, procedimiento sp_ejecutar_controles y vistas del dashboard.
Ejecutar desde la raíz del proyecto:  python scripts/desplegar.py
Costo: 0. Las sentencias CREATE no leen datos.
"""
from pathlib import Path

from google.cloud import bigquery

SQL = Path("sql")
LIMITE_BYTES = 10**9  # tope de seguridad: ninguna consulta puede facturar más de 1 GB


def union_controles() -> str:
    """Une todos los controles con UNION ALL. Los archivos de sql/controles/ son la única fuente de verdad."""
    bloques = []
    for archivo in sorted((SQL / "controles").glob("*.sql")):
        lineas = [l for l in archivo.read_text(encoding="utf-8").splitlines() if not l.lstrip().startswith("--")]
        bloques.append(f"-- {archivo.name}\n" + "\n".join(lineas).strip().rstrip(";"))
    return "\nUNION ALL\n".join(bloques)


def consulta_maestra() -> str:
    controles = "\n".join("    " + l for l in union_controles().splitlines())
    return f"""-- GENERADO por scripts/desplegar.py a partir de sql/controles/*.sql. No editar a mano.
-- Consulta maestra: ejecuta todos los controles y agrega una fila por control a resultados_controles.
-- Está dentro de un procedimiento para que la Scheduled Query solo tenga que hacer CALL.
CREATE OR REPLACE PROCEDURE `riesgos_dq.sp_ejecutar_controles`()
BEGIN
  INSERT INTO `riesgos_dq.resultados_controles`
    (fecha_ejecucion, nombre_control, dimension, campo, registros_evaluados, registros_fallidos, pct_error, umbral, estado)
  WITH controles AS (
{controles}
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
"""


def ejecutar(cliente: bigquery.Client, sql: str) -> bigquery.QueryJob:
    job = cliente.query(sql, job_config=bigquery.QueryJobConfig(maximum_bytes_billed=LIMITE_BYTES))
    job.result()
    return job


if __name__ == "__main__":
    (SQL / "01_consulta_maestra.sql").write_text(consulta_maestra(), encoding="utf-8")
    print("Generado: sql/01_consulta_maestra.sql")

    cliente = bigquery.Client()
    for archivo in sorted(SQL.glob("*.sql")):
        ejecutar(cliente, archivo.read_text(encoding="utf-8"))
        print(f"Desplegado: {archivo}")
