-- Create markethac.report_monthly_orders_product_base table --
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

-- Create markethac.report_monthly_orders_product_agg table --
CREATE TABLE markethac.report_monthly_orders_product_agg AS
SELECT
    year,
    month,
    category,
    name,
    brand,
    SUM(order_id) AS total_sold,
    SUM(order_id*retail_price) AS revenue,
    SUM(order_id*cost) AS COGS,
    SUM(order_id*(retail_price-cost)) AS profit
FROM 
    markethac.report_monthly_orders_product_base
GROUP BY
    month, year, category, name, brand;

-- Select the top product based on profit for each month in 2024 --
SELECT
    year,
    month,
    category,
    name,
    brand,
    profit,
FROM (
    SELECT
        year,
        month,
        category,
        name,
        brand,
        profit,
        RANK() OVER (PARTITION BY year, month ORDER BY profit DESC) AS rank
    FROM markethac.report_monthly_orders_product_agg
) ranked_products
WHERE 
    rank = 1 
      AND 
    year = 2024
ORDER BY 
    profit DESC;
