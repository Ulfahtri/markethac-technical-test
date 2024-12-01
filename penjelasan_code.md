# Penjelasan Code bigquary_syntax.sql

## 1. Membuat base tabel 

Base tabel berisi kolom-kolom yang digunakan untuk menyajikan informasi penjualan dari tahun 2019 hingga 2024. Kolom-kolom tersebut meliputi ```order_id```, ```product_id```, ```month```, ```year```, ```category```, ```name```, ```brand```, ```department```, ```retail_price```, dan ```cost```. Base tabel hanya memuat data penjualan yang memiliki status tidak terjadi return/pengembalian barang.

Code:

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

Penjelasan:

1. ```CREATE TABLE```: untuk membuat tabel baru.
2. ```AS```: untuk membuat tabel baru berdasarkan hasil query dari tabel yang sudah ada dan memberi alias atau mendefinisikan nama kolom.
3. ```FORMAT_TIMESTAMP```: untuk extract nama bulan dari tanggal.
4. ```EXTRACT(YEAR FROM nama_kolom)```: untuk extract tahun dari tanggal.
5. ```FROM bigquery-public-data.thelook_ecommerce.order_items```: untuk mengakses data dari tabel order_items pada dataset ```thelook_ecommerce``` dari ```bigquery-public-data```.
6. ```INNER JOIN```: untuk menggabungkan dua tabel berdasarkan kondisi tertentu. Dalam hal ini, kolom yang diambil meliputi ```category```, ```name```, ```brand```, ```department```, ```retail_price```, dan ```cost``` dari tabel ```products```.
7. ```ON```: pada query ```INNER JOIN```, query ini digunakan untuk menentukan kondisi atau aturan yang digunakan untuk mencocokkan kolom dari dua tabel yang digabungkan. Dalam hal ini kolom yang digunakan untuk mencocokan pada tabel ```order_items``` adalah ```product_id``` sedangkan pada tabel ```products``` adalah ```id```.
8. ```WHERE```: untuk membatasi data yang diambil dengan kondisi tertentu, dalam hal ini digunakan ```od.status != 'Returned'``` digunakan untuk memfilter status yang berisi "Returned" agar tidak disertakan dalam hasil query.

## 2. Membuat aggregate tabel 

Aggregate tabel berisi kolom-kolom yang menggunakan fungsi aggregate seperti ```SUM``` dan ```COUNT``` untuk memberikan informasi yang lebih luas mengenai data hasil penjualan. Kolom tersebut adalah ```total_sold```, ```revenue```, ```COGS```, dan ```profit```. 
1. ```total_sold```: jumlah unit produk yang terjual
2. ```revenue```: total pendapatan yang diperoleh dari penjualan produk
3. ```COGS```: total biaya yang dikeluarkan untuk memproduksi barang yang terjual
4. ```profit```: keuntungan yang diperoleh setelah dikurangi ```COGS``` dan ```revenue```.

Code:

```
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
```

Penjelasan:

1. ```SUM()```: untuk menghitung jumlah total dari nilai-nilai dalam kolom tertentu.
2. ```*```: memiki 2 fungsi, yaitu pertama pada perhitungan digunakan untuk operasi perkalian antar kolom. Kedua digunakan untuk memilih semua kolom dalam query saat digunakan pada ```SELECT * FROM```.
3. ```GROUP BY```: untuk mengelompokkan data berdasarkan satu atau lebih kolom yang ditentukan. Fungsi ini berguna ketika menggunakan fungsi agregat untuk melakukan perhitungan pada data yang dikelompokkan.

## 3. Memilih produk terbaik berdasarkan profit per bulan pada tahun 2024



Code:

```
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
```

Penjelasan:

1. ```RANK() OVER (PARTITION BY year, month ORDER BY profit DESC)```: merupakan window function yang digunakan untuk memberikan peringkat pada setiap produk berdasarkan profit bulanan, di mana produk dengan profit tertinggi di setiap bulan akan mendapatkan peringkat teratas. ```PARTITION BY``` digunakan untuk membagi data berdasarkan tahun dan bulan
2. ```rank = 1```: untuk mengambil 1 produk yang memiliki profit tertinggi.
3. ```AND```: untuk menggabungkan dua atau lebih kondisi dalam WHERE. Semua kondisi yang digabungkan dengan AND harus dipenuhi.
4. ```ORDER BY```: untuk mengurutkan berdasarkan kolom tertentu.
5. ```DESC```: untuk untuk mengurutkan kolom dari yang terbesar ke terkecil/menurun.
