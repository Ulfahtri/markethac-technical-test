# Penjelasan Code bigquary_syntax.sql

## 1. Membuat base tabel 

Base tabel berisi kolom-kolom yang menyajikan informasi mengenai penjualan 

```
CREATE TABLE markethac.report_monthly_orders_product_base AS
SELECT 
    od.order_id,
    od.product_id,
    FORMAT_TIMESTAMP('%B', od.created_at) AS month,
    EXTRACT(YEAR FROM od.created_at) AS year,
    pd.category,
    pd.name,
    pd.brand,
    pd.department,
    pd.retail_price,
    pd.cost
FROM 
    bigquery-public-data.thelook_ecommerce.order_items od
INNER JOIN 
    bigquery-public-data.thelook_ecommerce.products pd ON od.product_id = pd.id 
WHERE 
    od.status != 'Returned';
```
