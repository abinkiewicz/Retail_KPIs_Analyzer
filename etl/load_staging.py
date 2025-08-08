import psycopg2
import pandas as pd

#add to .env!
conn = psycopg2.connect(
    dbname="my_base",
    user="postgres",
    password="password",
    host="localhost",
    port="5432"
)

cur = conn.cursor()

cur.execute("""
    SELECT product_id, SUM(sales) AS total_sales
    FROM sales
    GROUP BY product_id
    ORDER BY total_sales DESC
    LIMIT 10;
""")

rows = cur.fetchall()
for row in rows:
    print(row)

cur.close()
conn.close()
