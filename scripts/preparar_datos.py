"""Paso 1: revisa data/cs-training.csv, renombra columnas al español y genera data/clientes_credito.csv.

Ejecutar desde la raíz del proyecto:  python scripts/preparar_datos.py
"""
import pandas as pd

# Orden del CSV original -> nombre en español. El orden importa: BigQuery carga CSV por posición.
COLUMNAS = {
    "Unnamed: 0": "id_cliente",
    "SeriousDlqin2yrs": "mora_grave_2_anios",
    "RevolvingUtilizationOfUnsecuredLines": "ratio_uso_lineas_rotativas",
    "age": "edad",
    "NumberOfTime30-59DaysPastDueNotWorse": "num_atrasos_30_59_dias",
    "DebtRatio": "ratio_deuda",
    "MonthlyIncome": "ingreso_mensual",
    "NumberOfOpenCreditLinesAndLoans": "num_creditos_abiertos",
    "NumberOfTimes90DaysLate": "num_atrasos_90_dias",
    "NumberRealEstateLoansOrLines": "num_creditos_hipotecarios",
    "NumberOfTime60-89DaysPastDueNotWorse": "num_atrasos_60_89_dias",
    "NumberOfDependents": "num_dependientes",
}

pd.set_option("display.width", 200)
df = pd.read_csv("data/cs-training.csv")
assert list(df.columns) == list(COLUMNAS), f"Columnas inesperadas: {list(df.columns)}"
df = df.rename(columns=COLUMNAS)

# pandas guarda enteros con nulos como float ("2.0"); Int64 los escribe como "2" y deja el nulo vacío, que BigQuery lee como INT64 NULL
df["num_dependientes"] = df["num_dependientes"].astype("Int64")

print(f"Filas: {len(df):,} | Columnas: {df.shape[1]}")
print(f"id_cliente único: {df['id_cliente'].is_unique}\n")
print("Tipos y % de nulos:")
print(pd.DataFrame({"tipo": df.dtypes, "pct_nulos": df.isna().mean().mul(100).round(2)}), "\n")
print("Estadísticas (busca mínimos y máximos raros):")
print(df.describe().T.round(2))

df.to_csv("data/clientes_credito.csv", index=False)
print("\nGenerado: data/clientes_credito.csv")
