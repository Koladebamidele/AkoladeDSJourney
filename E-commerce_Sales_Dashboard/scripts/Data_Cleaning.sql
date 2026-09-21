-- olist_orders_dataset: The central fact table — one row per order, carrying the order lifecycle 
-- (purchase → approval → carrier handoff → customer delivery → estimated delivery). 
-- It's the anchor for revenue timing, delivery performance (Objective 4), and order volume KPIs.

SELECT * FROM olist_orders;

-- Alter the datatype in the order_approved_at columns
ALTER TABLE olist_orders 
ALTER COLUMN order_approved_at 
TYPE TIMESTAMP WITHOUT TIME ZONE 
USING order_approved_at::timestamp without time zone;

--1. count ROWS
SELECT COUNT(*) AS row_counts FROM olist_orders;

--2. Duplicate order_id check
SELECT order_id, COUNT(*)
FROM olist_orders
GROUP BY order_id
HAVING COUNT(*) > 1;

--3. Null counts per date column
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE order_approved_at IS NULL) AS null_approved,
    COUNT(*) FILTER (WHERE order_delivered_carrier_date IS NULL) AS null_carrier,
    COUNT(*) FILTER (WHERE order_delivered_customer_date IS NULL) AS null_delivered_customer
FROM olist_orders;

--4. Order status distribution
SELECT order_status, COUNT(*) AS order_count
FROM olist_orders
GROUP BY order_status
ORDER BY order_count DESC;

--5. Logical date sequence violations
SELECT order_id, order_purchase_timestamp, order_approved_at,
       order_delivered_carrier_date, order_delivered_customer_date
FROM olist_orders
WHERE order_approved_at < order_purchase_timestamp;
	-- OR order_delivered_carrier_date < order_approved_at;
	-- OR order_delivered_customer_date < order_delivered_carrier_date;

-- 6. Orphaned customer_id (referential integrity)
SELECT o.customer_id
FROM olist_orders o
LEFT JOIN olist_customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- olist_order_items_dataset: The line-item grain — one row per product within an order (an order with 3 different products has 3 rows).
-- It carries price and freight_value, and feeds directly into revenue, average order value, and product-category performance (Objectives 1 and 3). 
-- It's also where seller_id lives, linking orders to sellers.

SELECT * FROM olist_order_items;

-- 1. Total rows / structural baseline
SELECT COUNT(*) AS total_rows FROM olist_order_items;

-- 2. Null check across key columns
SELECT
    COUNT(*) FILTER (WHERE order_id IS NULL) AS null_order_id,
    COUNT(*) FILTER (WHERE product_id IS NULL) AS null_product_id,
    COUNT(*) FILTER (WHERE seller_id IS NULL) AS null_seller_id,
    COUNT(*) FILTER (WHERE price IS NULL) AS null_price,
    COUNT(*) FILTER (WHERE freight_value IS NULL) AS null_freight,
    COUNT(*) FILTER (WHERE shipping_limit_date IS NULL) AS null_shipping_date
FROM olist_order_items;

-- 3. Composite key duplicate check (order_id + order_item_id should be unique)
SELECT order_id, order_item_id, COUNT(*)
FROM olist_order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

-- 4. Invalid values: zero or negative price/freight
SELECT COUNT(*) FILTER (WHERE price <= 0) AS zero_or_negative_price,
       COUNT(*) FILTER (WHERE freight_value < 0) AS negative_freight
FROM olist_order_items;

-- 5. Outlier scan: distribution of price and freight_value
SELECT
    MIN(price) AS min_price, MAX(price) AS max_price,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price) AS median_price,
    AVG(price) AS avg_price,
    MIN(freight_value) AS min_freight, MAX(freight_value) AS max_freight,
    AVG(freight_value) AS avg_freight
FROM olist_order_items;

-- 6. Referential integrity: orphaned order_id
SELECT oi.order_id
FROM olist_order_items oi
LEFT JOIN olist_orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- 7. Referential integrity: orphaned product_id
SELECT oi.product_id
FROM olist_order_items oi
LEFT JOIN olist_products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- 8. Referential integrity: orphaned seller_id
SELECT oi.seller_id
FROM olist_order_items oi
LEFT JOIN olist_sellers s ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

-- 9. shipping_limit_date earlier than the order was even placed
SELECT oi.order_id, oi.order_item_id, oi.shipping_limit_date, o.order_purchase_timestamp
FROM olist_order_items oi
JOIN olist_orders o ON oi.order_id = o.order_id
WHERE oi.shipping_limit_date < o.order_purchase_timestamp;


-- olist_order_payments_dataset: This table defines revenue for the entire project.

SELECT * FROM olist_order_payments;

-- 1. Total rows / structural baseline
SELECT COUNT(*) AS total_rows FROM olist_order_payments;

-- 2. Null check across key columns
SELECT
    COUNT(*) FILTER (WHERE order_id IS NULL) AS null_order_id,
    COUNT(*) FILTER (WHERE payment_type IS NULL) AS null_payment_type,
    COUNT(*) FILTER (WHERE payment_installments IS NULL) AS null_installments,
    COUNT(*) FILTER (WHERE payment_value IS NULL) AS null_payment_value
FROM olist_order_payments;

-- 3. Composite key duplicate check
SELECT order_id, payment_sequential, COUNT(*)
FROM olist_order_payments
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1;

-- 4. Invalid values: zero/negative payment_value, zero/negative installments
SELECT
    COUNT(*) FILTER (WHERE payment_value <= 0) AS zero_or_negative_payment,
    COUNT(*) FILTER (WHERE payment_installments <= 0) AS zero_or_negative_installments
FROM olist_order_payments;

-- 5. payment_type distribution
SELECT payment_type, COUNT(*) AS row_count, SUM(payment_value) AS total_value
FROM olist_order_payments
GROUP BY payment_type
ORDER BY row_count DESC;

-- 6. Outlier scan: payment_value distribution
SELECT
    MIN(payment_value) AS min_value, MAX(payment_value) AS max_value,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY payment_value) AS median_value,
    AVG(payment_value) AS avg_value,
    MAX(payment_installments) AS max_installments
FROM olist_order_payments;

-- 7. Referential integrity: orphaned order_id
SELECT op.order_id
FROM olist_order_payments op
LEFT JOIN olist_orders o ON op.order_id = o.order_id
WHERE o.order_id IS NULL;

-- 8. Business logic sanity check: payments vs. order_items totals per order
-- (large mismatches worth a look, not necessarily errors)
SELECT
    p.order_id,
    p.total_payment,
    i.total_items_value,
    p.total_payment - i.total_items_value AS difference
FROM (
    SELECT order_id, SUM(payment_value) AS total_payment
    FROM olist_order_payments
    GROUP BY order_id
) p
JOIN (
    SELECT order_id, SUM(price + freight_value) AS total_items_value
    FROM olist_order_items
    GROUP BY order_id
) i ON p.order_id = i.order_id
WHERE ABS(p.total_payment - i.total_items_value) > 50  -- threshold, adjust as needed
ORDER BY difference DESC
LIMIT 20;


-- olist_customers_dataset: This table drives your demand-side geographic analysis (Objective 3) — per your 
-- Business Understanding doc's Key Assumptions, geography is analyzed using customer_state/customer_city, 
-- not seller location. It's also the join point between orders and customer identity.

SELECT * FROM olist_customers;

-- 1. Total rows / structural baseline
SELECT COUNT(*) AS total_rows FROM olist_customers;

-- 2. Null check across key columns
SELECT
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS null_customer_id,
    COUNT(*) FILTER (WHERE customer_unique_id IS NULL) AS null_unique_id,
    COUNT(*) FILTER (WHERE customer_zip_code_prefix IS NULL) AS null_zip,
    COUNT(*) FILTER (WHERE customer_city IS NULL) AS null_city,
    COUNT(*) FILTER (WHERE customer_state IS NULL) AS null_state
FROM olist_customers;

-- 3. Duplicate check on customer_id (should be unique)
SELECT customer_id, COUNT(*)
FROM olist_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- 4. Confirm the customer_unique_id repeat pattern (should show many customer_unique_id
--    values tied to multiple customer_id values — this is expected, not an error)
SELECT customer_unique_id, COUNT(DISTINCT customer_id) AS distinct_customer_ids
FROM olist_customers
GROUP BY customer_unique_id
HAVING COUNT(DISTINCT customer_id) > 1
ORDER BY distinct_customer_ids DESC
LIMIT 10;

-- 5. Text formatting check: case/whitespace inconsistencies in customer_city
SELECT DISTINCT customer_city
FROM olist_customers
WHERE customer_city <> LOWER(TRIM(customer_city))
LIMIT 20;

-- 6. Valid state code check (Brazil has 27 valid UF codes)
SELECT DISTINCT customer_state
FROM olist_customers
ORDER BY customer_state;

SELECT COUNT(DISTINCT customer_state) AS distinct_count
FROM olist_customers;

-- 7. Zip code sanity check
SELECT
    MIN(customer_zip_code_prefix::numeric) AS min_zip,
    MAX(customer_zip_code_prefix::numeric) AS max_zip,
    COUNT(*) FILTER (WHERE customer_zip_code_prefix::numeric <= 0) AS invalid_zip_count
FROM olist_customers;

--	Zip code datatype is stored as integers instead of text hence, making some 5 digit codes
--	starting with 0 to be truncated into 4 digit codes. The entire customer zip code prefix 
--	will be altered.

-- a. Change the column type to VARCHAR/TEXT
ALTER TABLE olist_customers ALTER COLUMN customer_zip_code_prefix TYPE VARCHAR(5);

-- b. Add the missing leading zeros back to the data
UPDATE olist_customers SET customer_zip_code_prefix = LPAD(customer_zip_code_prefix, 5, '0');

SELECT * FROM olist_customers;

-- 8. Referential integrity: orphaned customer_id in orders not found in customers
SELECT o.customer_id
FROM olist_orders o
LEFT JOIN olist_customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- olist_geolocation_dataset: Reference/lookup table mapping zip code prefixes to lat/lng coordinates and 
-- city/state - used to enrich customer or seller geography with map coordinates for spatial visualizations. 
-- It is not a fact table and typically doesn't join 1:1 to anything; it needs to be aggregated 
-- (e.g., averaged per zip prefix) before use.

SELECT * FROM olist_geolocation;

-- a. Change the column type to VARCHAR/TEXT
ALTER TABLE olist_geolocation ALTER COLUMN geolocation_zip_code_prefix TYPE VARCHAR(5);

-- b. Add the missing leading zeros back to the data
UPDATE olist_geolocation SET geolocation_zip_code_prefix = LPAD(geolocation_zip_code_prefix, 5, '0');

SELECT * FROM olist_customers;

-- 1. Total rows / structural baseline
SELECT COUNT(*) AS total_rows FROM olist_geolocation;

-- 2. Null check across all columns
SELECT
    COUNT(*) FILTER (WHERE geolocation_zip_code_prefix IS NULL) AS null_zip,
    COUNT(*) FILTER (WHERE geolocation_lat IS NULL) AS null_lat,
    COUNT(*) FILTER (WHERE geolocation_lng IS NULL) AS null_lng,
    COUNT(*) FILTER (WHERE geolocation_city IS NULL) AS null_city,
    COUNT(*) FILTER (WHERE geolocation_state IS NULL) AS null_state
FROM olist_geolocation;

-- 3. Uniqueness check on zip_code_prefix
-- (Expect MANY duplicates here — this is normal, not a data quality error,
-- since multiple lat/lng points can share the same zip prefix. This query
-- just quantifies how many rows exist per prefix, for context.)
SELECT geolocation_zip_code_prefix, COUNT(*) AS row_count
FROM olist_geolocation
GROUP BY geolocation_zip_code_prefix
ORDER BY row_count DESC
LIMIT 10;

-- 4. Full duplicate rows (exact duplicates across all 5 columns —
-- THIS is the real duplicate check, unlike #3)
SELECT geolocation_zip_code_prefix, geolocation_lat, geolocation_lng,
       geolocation_city, geolocation_state, COUNT(*)
FROM olist_geolocation
GROUP BY geolocation_zip_code_prefix, geolocation_lat, geolocation_lng,
         geolocation_city, geolocation_state
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC
LIMIT 20;

-- 5. Text formatting check: casing/whitespace inconsistencies in city
SELECT DISTINCT geolocation_city
FROM olist_geolocation
WHERE geolocation_city <> LOWER(TRIM(geolocation_city))
LIMIT 30;

-- 6. Valid state code check (27 valid Brazilian UF codes)
SELECT DISTINCT geolocation_state
FROM olist_geolocation
ORDER BY geolocation_state;

SELECT COUNT(DISTINCT geolocation_state)
FROM olist_geolocation;

-- 7. Bounding-box sanity check for lat/lng
-- Brazil's approximate bounds: latitude -34 to +5.5, longitude -74 to -34
SELECT COUNT(*) AS out_of_bounds_count
FROM olist_geolocation
WHERE geolocation_lat < -34 OR geolocation_lat > 5.5
   OR geolocation_lng < -74 OR geolocation_lng > -34;

-- 8. Sample of the actual out-of-bounds rows, if any, to eyeball severity
SELECT *
FROM olist_geolocation
WHERE geolocation_lat < -34 OR geolocation_lat > 5.5
   OR geolocation_lng < -74 OR geolocation_lng > -34
LIMIT 20;

-- 9. Zip code prefix format check — confirm digit length consistency
-- (same leading-zero risk as the customers table if stored as integer)
SELECT
    LENGTH(geolocation_zip_code_prefix::text) AS zip_length,
    COUNT(*) AS row_count
FROM olist_geolocation
GROUP BY LENGTH(geolocation_zip_code_prefix::text)
ORDER BY zip_length;


-- olist_products_dataset + product_category_name_translation: This pair of tables drives product category performance (Objective 3).
-- products holds physical attributes (weight, dimensions, photo count) and links to order_items via product_id. 
-- The translation table is a simple lookup converting Portuguese category names to English — needed because your 
-- dashboard will presumably report in English.

SELECT * FROM olist_products;
SELECT * FROM product_category_name_translation;

-- 1. Total rows / structural baseline
SELECT COUNT(*) AS total_rows FROM olist_products;
SELECT COUNT(*) AS total_rows FROM product_category_name_translation;

-- 2. Null check across all product columns
SELECT
    COUNT(*) FILTER (WHERE product_id IS NULL) AS null_product_id,
    COUNT(*) FILTER (WHERE product_category_name IS NULL) AS null_category,
    COUNT(*) FILTER (WHERE product_name_lenght IS NULL) AS null_name_length,
    COUNT(*) FILTER (WHERE product_description_lenght IS NULL) AS null_desc_length,
    COUNT(*) FILTER (WHERE product_photos_qty IS NULL) AS null_photos_qty,
    COUNT(*) FILTER (WHERE product_weight_g IS NULL) AS null_weight,
    COUNT(*) FILTER (WHERE product_length_cm IS NULL) AS null_length,
    COUNT(*) FILTER (WHERE product_height_cm IS NULL) AS null_height,
    COUNT(*) FILTER (WHERE product_width_cm IS NULL) AS null_width
FROM olist_products;

-- 3. Duplicate check on product_id
SELECT product_id, COUNT(*)
FROM olist_products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- 4. Invalid values: zero/negative weight or dimensions
SELECT
    COUNT(*) FILTER (WHERE product_weight_g <= 0) AS invalid_weight,
    COUNT(*) FILTER (WHERE product_length_cm <= 0) AS invalid_length,
    COUNT(*) FILTER (WHERE product_height_cm <= 0) AS invalid_height,
    COUNT(*) FILTER (WHERE product_width_cm <= 0) AS invalid_width,
    COUNT(*) FILTER (WHERE product_photos_qty <= 0) AS zero_photos
FROM olist_products;

-- 5. Outlier scan: weight and dimension distribution
SELECT
    MIN(product_weight_g) AS min_weight, MAX(product_weight_g) AS max_weight,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY product_weight_g) AS median_weight,
    AVG(product_weight_g) AS avg_weight,
    MIN(product_length_cm) AS min_length, MAX(product_length_cm) AS max_length,
    MIN(product_height_cm) AS min_height, MAX(product_height_cm) AS max_height,
    MIN(product_width_cm) AS min_width, MAX(product_width_cm) AS max_width
FROM olist_products;

-- 6. Category names in products NOT found in translation table
SELECT DISTINCT p.product_category_name
FROM olist_products p
LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND t.product_category_name IS NULL;

-- 7. Duplicate check on translation table (Portuguese name should be unique)
SELECT product_category_name, COUNT(*)
FROM product_category_name_translation
GROUP BY product_category_name
HAVING COUNT(*) > 1;

-- 8. Null check on translation table
SELECT
    COUNT(*) FILTER (WHERE product_category_name IS NULL) AS null_pt_name,
    COUNT(*) FILTER (WHERE product_category_name_english IS NULL) AS null_en_name
FROM product_category_name_translation;

-- 9. Referential integrity: orphaned product_id in order_items not found in products
SELECT oi.product_id
FROM olist_order_items oi
LEFT JOIN olist_products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

SELECT product_id, product_category_name, product_weight_g,
       product_length_cm, product_height_cm, product_width_cm
FROM olist_products
WHERE product_weight_g = 0;