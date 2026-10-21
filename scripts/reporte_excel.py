"""Ejecuta los controles de calidad y genera un reporte Excel: hoja Resumen + hoja Detalle (registros que fallan en controles con ALERTA).

Ejecutar desde la raíz del proyecto:  python scripts/reporte_excel.py
Costo: cada ejecución lee unos pocos MB de clientes_credito (muy por debajo del 1 TB gratuito al mes).
El Excel contiene datos de clientes: se guarda en reportes/, que está en .gitignore.
"""
from datetime import datetime
from pathlib import Path

import pandas as pd
from google.cloud import bigquery

from desplegar import LIMITE_BYTES, ejecutar, union_controles

cliente = bigquery.Client()
bytes_totales = 0

job = ejecutar(cliente, "CALL `riesgos_dq.sp_ejecutar_controles`()")
bytes_totales += job.total_bytes_processed or 0

resumen = cliente.query("SELECT * FROM `riesgos_dq.v_estado_actual` ORDER BY nombre_control").to_dataframe()
alertas = resumen.loc[resumen["estado"] == "ALERTA", "nombre_control"].tolist()

detalle = pd.DataFrame(columns=["nombre_control", "id_cliente", "valor"])
if alertas:
    job = cliente.query(
        f"""SELECT nombre_control, id_cliente, valor
FROM (
{union_controles()}
)
WHERE evaluado AND fallido AND nombre_control IN UNNEST(@alertas)
ORDER BY nombre_control, id_cliente""",
        job_config=bigquery.QueryJobConfig(
            maximum_bytes_billed=LIMITE_BYTES,
            query_parameters=[bigquery.ArrayQueryParameter("alertas", "STRING", alertas)],
        ),
    )
    detalle = job.to_dataframe()
    bytes_totales += job.total_bytes_processed or 0

# Excel no admite fechas con zona horaria
resumen["fecha_ejecucion"] = resumen["fecha_ejecucion"].dt.tz_localize(None)

Path("reportes").mkdir(exist_ok=True)
salida = Path("reportes") / f"reporte_dq_{datetime.now():%Y%m%d_%H%M}.xlsx"
with pd.ExcelWriter(salida) as excel:
    resumen.to_excel(excel, sheet_name="Resumen", index=False)
    detalle.to_excel(excel, sheet_name="Detalle", index=False)

print(resumen[["estado", "nombre_control", "registros_fallidos", "pct_error", "umbral"]].to_string(index=False))
print(f"\nControles en ALERTA: {len(alertas)} | Registros en detalle: {len(detalle):,}")
print(f"Bytes procesados: {bytes_totales / 1e6:.1f} MB")
print(f"Reporte: {salida}")
