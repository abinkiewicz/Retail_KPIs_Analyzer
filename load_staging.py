import psycopg2
import pandas as pd

# Połączenie z PostgreSQL
conn = psycopg2.connect(
    dbname="moja_baza",
    user="postgres",
    password="haslo",
    host="localhost",
    port="5432"
)

cur = conn.cursor()

# Piszesz czyste SQL
cur.execute("""
    SELECT product_id, SUM(sales) AS total_sales
    FROM sales
    GROUP BY product_id
    ORDER BY total_sales DESC
    LIMIT 10;
""")

# Pobranie wyników
rows = cur.fetchall()
for row in rows:
    print(row)

cur.close()
conn.close()
