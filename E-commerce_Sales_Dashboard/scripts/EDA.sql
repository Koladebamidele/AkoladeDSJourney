-- Exploratory Data Analysis (EDA)

-- Total Revenue (Objective 1)
SELECT * FROM fact_orders;

SELECT
    order_status,
    COUNT(*) AS order_count,
    SUM(total_payment_value) AS total_revenue,
    ROUND(AVG(total_payment_value::numeric), 2) AS avg_order_value,
    ROUND(MIN(total_payment_value::numeric), 2) AS min_order_value,
    ROUND(MAX(total_payment_value::numeric), 2) AS max_order_value,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_payment_value::numeric) AS median_order_value
FROM fact_orders
GROUP BY order_status
ORDER BY total_revenue DESC;

SELECT
  order_status,
  COUNT(*) AS total_orders,
  COUNT(*) FILTER (WHERE order_approved_at IS NULL) AS null_approved,
  COUNT(*) FILTER (WHERE order_delivered_carrier_date IS NULL) AS null_carrier,
  COUNT(*) FILTER (WHERE order_delivered_customer_date IS NULL) AS null_delivered_customer,
  COUNT(*) FILTER (WHERE delivery_days IS NULL) AS null_delivery_days,
  COUNT(*) FILTER (WHERE is_on_time_delivery IS NULL) AS null_is_otd
FROM fact_orders
GROUP BY order_status
ORDER BY total_orders DESC;

WITH bucketed AS (
  SELECT
    order_id,
    total_payment_value,
    CASE
      WHEN total_payment_value = 0            THEN '0. Zero'
      WHEN total_payment_value <= 50          THEN '1. 0.01–50'
      WHEN total_payment_value <= 100         THEN '2. 50–100'
      WHEN total_payment_value <= 150         THEN '3. 100–150'
      WHEN total_payment_value <= 250         THEN '4. 150–250'
      WHEN total_payment_value <= 500         THEN '5. 250–500'
      WHEN total_payment_value <= 1000        THEN '6. 500–1000'
      ELSE                                    '7. 1000+'
    END AS value_bucket
  FROM fact_orders
  WHERE order_status = 'delivered'
)
SELECT
  value_bucket,
  COUNT(*) AS order_count,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_orders,
  ROUND(SUM(total_payment_value::numeric), 2) AS bucket_revenue,
  ROUND(100.0 * SUM(total_payment_value::numeric) / SUM(SUM(total_payment_value::numeric)) OVER (), 2) AS pct_of_revenue
FROM bucketed
GROUP BY value_bucket
ORDER BY value_bucket;

SELECT
  percentile_cont(0.5)  WITHIN GROUP (ORDER BY total_payment_value) AS p50_median,
  percentile_cont(0.75) WITHIN GROUP (ORDER BY total_payment_value) AS p75,
  percentile_cont(0.90) WITHIN GROUP (ORDER BY total_payment_value) AS p90,
  percentile_cont(0.95) WITHIN GROUP (ORDER BY total_payment_value) AS p95,
  percentile_cont(0.99) WITHIN GROUP (ORDER BY total_payment_value) AS p99,
  MAX(total_payment_value) AS max_value
FROM fact_orders
WHERE order_status = 'delivered';

-- Sales Trends (Objective 2)
SELECT
  DATE_TRUNC('month', order_purchase_timestamp)::date AS order_month,
  COUNT(DISTINCT order_id) AS total_orders,
  ROUND(SUM(total_payment_value::numeric), 2) AS total_revenue,
  ROUND(SUM(total_payment_value::numeric) / COUNT(DISTINCT order_id), 2) AS aov
FROM fact_orders
WHERE order_status = 'delivered'
GROUP BY 1
ORDER BY 1;

SELECT MIN(order_purchase_timestamp) AS first_order, MAX(order_purchase_timestamp) AS last_order
FROM fact_orders
WHERE order_status = 'delivered';

WITH monthly AS (
  SELECT
    DATE_TRUNC('month', order_purchase_timestamp)::date AS order_month,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(total_payment_value::numeric) AS total_revenue
  FROM fact_orders
  WHERE order_status = 'delivered'
    AND order_purchase_timestamp >= '2017-01-01'
    AND order_purchase_timestamp <  '2018-09-01'
  GROUP BY 1
)
SELECT
  order_month,
  total_orders,
  ROUND(total_revenue, 2) AS total_revenue,
  ROUND(total_revenue / total_orders, 2) AS aov,
  ROUND(100.0 * (total_revenue - LAG(total_revenue) OVER (ORDER BY order_month))
        / NULLIF(LAG(total_revenue) OVER (ORDER BY order_month), 0), 2) AS mom_revenue_growth_pct,
  ROUND(100.0 * (total_revenue - LAG(total_revenue, 12) OVER (ORDER BY order_month))
        / NULLIF(LAG(total_revenue, 12) OVER (ORDER BY order_month), 0), 2) AS yoy_revenue_growth_pct
FROM monthly
ORDER BY order_month;

SELECT
  order_purchase_timestamp::date AS order_day,
  EXTRACT(DOW FROM order_purchase_timestamp) AS day_of_week,  -- 0=Sunday
  COUNT(DISTINCT order_id) AS total_orders,
  ROUND(SUM(total_payment_value::numeric), 2) AS total_revenue
FROM fact_orders
WHERE order_status = 'delivered'
  AND order_purchase_timestamp >= '2017-11-01'
  AND order_purchase_timestamp <  '2017-12-01'
GROUP BY 1, 2
ORDER BY 1;

-- Quarterly
SELECT
  DATE_TRUNC('quarter', order_purchase_timestamp)::date AS order_quarter,
  COUNT(DISTINCT order_id) AS total_orders,
  ROUND(SUM(total_payment_value::numeric), 2) AS total_revenue,
  ROUND(SUM(total_payment_value::numeric) / COUNT(DISTINCT order_id), 2) AS aov
FROM fact_orders
WHERE order_status = 'delivered'
  AND order_purchase_timestamp >= '2017-01-01'
  AND order_purchase_timestamp <  '2018-09-01'
GROUP BY 1
ORDER BY 1;

-- Yearly (note: 2018 will be a partial year — Jan through Aug only)
SELECT
  DATE_TRUNC('year', order_purchase_timestamp)::date AS order_year,
  COUNT(DISTINCT order_id) AS total_orders,
  ROUND(SUM(total_payment_value::numeric), 2) AS total_revenue,
  ROUND(SUM(total_payment_value::numeric) / COUNT(DISTINCT order_id), 2) AS aov
FROM fact_orders
WHERE order_status = 'delivered'
  AND order_purchase_timestamp >= '2017-01-01'
  AND order_purchase_timestamp <  '2018-09-01'
GROUP BY 1
ORDER BY 1;


-- Product Performance (Objective 3)
SELECT * FROM fact_order_items;
SELECT * FROM fact_orders;
SELECT * FROM fact_payments;
SELECT * FROM dim_product;

WITH item_categories AS (
  SELECT
    oi.order_id,
    oi.price,
    COALESCE(p.product_category, 'Uncategorized') AS category
  FROM fact_order_items oi
  JOIN fact_orders o ON o.order_id = oi.order_id
  LEFT JOIN dim_product p ON p.product_id = oi.product_id
  WHERE o.order_status = 'delivered'
)
SELECT
  category,
  COUNT(DISTINCT order_id) AS order_count,
  ROUND(SUM(price::numeric), 2) AS category_revenue,
  ROUND(SUM(price::numeric) / COUNT(DISTINCT order_id), 2) AS aov_by_category,
  ROUND(100.0 * SUM(price::numeric) / SUM(SUM(price::numeric)) OVER (), 2) AS pct_of_revenue
FROM item_categories
GROUP BY category
ORDER BY category_revenue DESC;

--category growth %
WITH item_categories AS (
  SELECT
    oi.order_id,
    oi.price,
    o.order_purchase_timestamp,
    COALESCE(p.product_category, 'Uncategorized') AS category
  FROM fact_order_items oi
  JOIN fact_orders o ON o.order_id = oi.order_id
  LEFT JOIN dim_product p ON p.product_id = oi.product_id
  WHERE o.order_status = 'delivered'
    AND (
      (o.order_purchase_timestamp >= '2017-01-01' AND o.order_purchase_timestamp < '2017-09-01')
      OR
      (o.order_purchase_timestamp >= '2018-01-01' AND o.order_purchase_timestamp < '2018-09-01')
    )
),
period_revenue AS (
  SELECT
    category,
    CASE
      WHEN order_purchase_timestamp < '2017-09-01' THEN 'period_2017'
      ELSE 'period_2018'
    END AS period,
    SUM(price) AS revenue,
    COUNT(DISTINCT order_id) AS orders
  FROM item_categories
  GROUP BY category, period
)
SELECT
  category,
  MAX(CASE WHEN period = 'period_2017' THEN orders END)  AS orders_2017,
  MAX(CASE WHEN period = 'period_2017' THEN revenue END) AS revenue_2017,
  MAX(CASE WHEN period = 'period_2018' THEN orders END)  AS orders_2018,
  MAX(CASE WHEN period = 'period_2018' THEN revenue END) AS revenue_2018,
  100.0 * (MAX(CASE WHEN period = 'period_2018' THEN revenue END) - MAX(CASE WHEN period = 'period_2017' THEN revenue END))
    / NULLIF(MAX(CASE WHEN period = 'period_2017' THEN revenue END), 0) AS revenue_growth_pct
FROM period_revenue
GROUP BY category
ORDER BY revenue_growth_pct DESC NULLS LAST;


-- Geographic Performance (Objective 4)
SELECT * FROM dim_customer;
SELECT
  c.customer_state,
  COUNT(DISTINCT o.order_id) AS total_orders,
  ROUND(SUM(o.total_payment_value::numeric), 2) AS total_revenue,
  ROUND(SUM(o.total_payment_value::numeric) / COUNT(DISTINCT o.order_id), 2) AS aov,
  ROUND(100.0 * SUM(o.total_payment_value::numeric) / SUM(SUM(o.total_payment_value::numeric)) OVER (), 2) AS pct_of_revenue,
  ROUND(100.0 * COUNT(DISTINCT o.order_id) / SUM(COUNT(DISTINCT o.order_id)) OVER (), 2) AS pct_of_orders
FROM fact_orders o
JOIN dim_customer c ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_revenue DESC;

SELECT
  c.customer_city,
  c.customer_state,
  COUNT(DISTINCT o.order_id) AS total_orders,
  ROUND(SUM(o.total_payment_value::numeric), 2) AS total_revenue
FROM fact_orders o
JOIN dim_customer c ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_city, c.customer_state
ORDER BY total_revenue DESC
LIMIT 15;


-- Delivery Performance (Objective 5)


SELECT
  COUNT(*) AS eligible_orders,
  100.0 * SUM(CASE WHEN is_on_time_delivery THEN 1 ELSE 0 END) / COUNT(*) AS on_time_delivery_rate_pct,
  100.0 * SUM(CASE WHEN NOT is_on_time_delivery THEN 1 ELSE 0 END) / COUNT(*) AS late_delivery_rate_pct,
  AVG(delivery_days) AS avg_delivery_time_days,
  AVG(order_delivered_customer_date - order_estimated_delivery_date) AS avg_delivery_delay_days
FROM fact_orders
WHERE order_status = 'delivered'
  AND delivery_days IS NOT NULL;

SELECT
	AVG(EXTRACT(EPOCH FROM (order_delivered_customer_date - order_estimated_delivery_date))) / 86400.0 AS avg_delivery_delay_days
FROM fact_orders
WHERE order_status = 'delivered'
  AND delivery_days IS NOT NULL;

-- state and time breakdown
SELECT
  c.customer_state,
  COUNT(*) AS eligible_orders,
  100.0 * SUM(CASE WHEN is_on_time_delivery THEN 1 ELSE 0 END) / COUNT(*) AS on_time_rate_pct,
  AVG(delivery_days) AS avg_delivery_time_days,
  AVG(EXTRACT(EPOCH FROM (order_delivered_customer_date - order_estimated_delivery_date))) / 86400.0 AS avg_delivery_delay_days
FROM fact_orders o
JOIN dim_customer c ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
  AND o.delivery_days IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_time_days DESC;

SELECT
  DATE_TRUNC('month', order_purchase_timestamp)::date AS order_month,
  COUNT(*) AS eligible_orders,
  100.0 * SUM(CASE WHEN is_on_time_delivery THEN 1 ELSE 0 END) / COUNT(*) AS on_time_rate_pct,
  AVG(delivery_days) AS avg_delivery_time_days,
  AVG(EXTRACT(EPOCH FROM (order_delivered_customer_date - order_estimated_delivery_date))) / 86400.0 AS avg_delivery_delay_days
FROM fact_orders
WHERE order_status = 'delivered'
  AND delivery_days IS NOT NULL
GROUP BY 1
ORDER BY 1;