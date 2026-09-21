-- SQL VIEWS

-- dim_date: enables consistent trend/seasonality analysis and is the shared time dimension across all three facts. 
-- Auto-generated to span actual order + estimated-delivery date range — no manual maintenance.
CREATE OR REPLACE VIEW dim_date AS
WITH bounds AS (
    SELECT
        MIN(order_purchase_timestamp)::date AS min_date,
        MAX(order_estimated_delivery_date)::date AS max_date
    FROM olist_orders
)
SELECT
    d::date                              AS date_key,
    EXTRACT(YEAR FROM d)::int            AS year,
    EXTRACT(QUARTER FROM d)::int         AS quarter,
    EXTRACT(MONTH FROM d)::int           AS month,
    TRIM(TO_CHAR(d, 'Month'))            AS month_name,
    TO_CHAR(d, 'YYYY-MM')                AS year_month,
    EXTRACT(WEEK FROM d)::int            AS week_of_year,
    EXTRACT(DAY FROM d)::int             AS day_of_month,
    TRIM(TO_CHAR(d, 'Day'))              AS day_name,
    (EXTRACT(ISODOW FROM d) IN (6, 7))   AS is_weekend
FROM bounds, generate_series(bounds.min_date, bounds.max_date, interval '1 day') AS d;

SELECT * FROM dim_date;

-- dim_customer: demand-side geography for Objective 3. 
-- Grain = customer_id (order-scoped), matching fact_orders 1:1.
CREATE OR REPLACE VIEW dim_customer AS
SELECT
    customer_id,
    customer_unique_id,
    customer_city,
    customer_state,
    customer_zip_code_prefix
FROM olist_customers;

SELECT * FROM dim_customer;

-- dim_product: category performance dimension. Resolves the 610 uncategorized products to an explicit bucket 
-- instead of dropping them, based on Phase 4 carried-forward note.
CREATE OR REPLACE VIEW dim_product AS
SELECT
    p.product_id,
    COALESCE(t.product_category_name_english, 'Uncategorized') AS product_category,
    (p.product_category_name IS NULL)                          AS is_uncategorized
FROM olist_products p
LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name;

SELECT * FROM dim_product;

-- fact_orders: order-grain fact powering Revenue, AOV, Sales Trends, and Delivery Performance. 
-- Aggregates payments to avoid double-counting, and computes delivery validity/on-time flags live.
CREATE OR REPLACE VIEW fact_orders AS
WITH payments_agg AS (
    SELECT
        order_id,
        SUM(payment_value) AS total_payment_value
    FROM olist_order_payments
    GROUP BY order_id
),
delivery_calc AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_purchase_timestamp::date AS order_purchase_date,
        o.order_status,
        o.order_purchase_timestamp,
        o.order_approved_at,
        o.order_delivered_carrier_date,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        (o.order_status = 'delivered') AS is_delivered,
        CASE
            WHEN o.order_status = 'delivered'
             AND o.order_delivered_customer_date IS NOT NULL
             AND (o.order_delivered_carrier_date IS NULL
                  OR o.order_delivered_carrier_date >= o.order_approved_at)
             AND o.order_delivered_customer_date >= o.order_delivered_carrier_date
            THEN TRUE ELSE FALSE
        END AS is_valid_delivery_sequence
    FROM olist_orders o
)
SELECT
    d.order_id,
    d.customer_id,
    d.order_purchase_date,
    d.order_status,
    d.is_delivered,
    d.order_purchase_timestamp,
    d.order_approved_at,
    d.order_delivered_carrier_date,
    d.order_delivered_customer_date,
    d.order_estimated_delivery_date,
    COALESCE(p.total_payment_value, 0) AS total_payment_value,
    d.is_valid_delivery_sequence,
    CASE WHEN d.is_valid_delivery_sequence
         THEN (d.order_delivered_customer_date::date - d.order_purchase_timestamp::date)
         ELSE NULL
    END AS delivery_days,
    CASE WHEN d.is_valid_delivery_sequence
         THEN (d.order_delivered_customer_date <= d.order_estimated_delivery_date)
         ELSE NULL
    END AS is_on_time_delivery
FROM delivery_calc d
LEFT JOIN payments_agg p ON d.order_id = p.order_id;

SELECT * FROM fact_orders;

-- fact_order_items: line-item grain fact powering product category performance (Objective 3).
CREATE OR REPLACE VIEW fact_order_items AS
SELECT
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    o.customer_id,
    o.order_purchase_timestamp::date AS order_purchase_date,
    o.order_status,
    oi.price,
    oi.freight_value,
    (oi.price + oi.freight_value) AS item_total_value
FROM olist_order_items oi
JOIN olist_orders o ON oi.order_id = o.order_id;

SELECT * FROM fact_order_items;

-- fact_payments: payment-installment grain fact powering the Finance payment-method breakdown, 
-- kept separate so it never distorts order-level revenue counts (an order can have multiple payment rows).
CREATE OR REPLACE VIEW fact_payments AS
SELECT
    op.order_id,
    op.payment_sequential,
    o.customer_id,
    o.order_purchase_timestamp::date AS order_purchase_date,
    o.order_status,
    op.payment_type,
    op.payment_installments,
    op.payment_value
FROM olist_order_payments op
JOIN olist_orders o ON op.order_id = o.order_id;

SELECT * FROM fact_payments;

-- validation checklist
SELECT 'fact_orders' AS view_name, COUNT(*) FROM fact_orders
UNION ALL
SELECT 'fact_order_items', COUNT(*) FROM fact_order_items
UNION ALL
SELECT 'fact_payments', COUNT(*) FROM fact_payments
UNION ALL
SELECT 'dim_customer', COUNT(*) FROM dim_customer
UNION ALL
SELECT 'dim_date', COUNT(*) FROM dim_date
UNION ALL
SELECT 'dim_product', COUNT(*) FROM dim_product;

-- indexes on base tables
CREATE INDEX IF NOT EXISTS idx_orders_purchase_ts ON olist_orders (order_purchase_timestamp);
CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON olist_orders (customer_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON olist_order_items (product_id);
CREATE INDEX IF NOT EXISTS idx_order_payments_order_id ON olist_order_payments (order_id);