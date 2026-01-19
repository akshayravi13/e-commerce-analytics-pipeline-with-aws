-- =============================================================================
-- Capstone Project: Event Analytics Pipeline
-- Student: aravi7
-- Database: capstone_aravi7_db
-- Table: processed_events
-- =============================================================================

-- Query 1: Conversion Funnel
-- For each product, calculate view → add_to_cart → purchase conversion rates
-- Business Question: What percentage of product views convert to cart additions and purchases?
SELECT 
    product_id,
    COUNT(CASE WHEN event_type = 'page_view' THEN 1 END) AS view_count,
    COUNT(CASE WHEN event_type = 'add_to_cart' THEN 1 END) AS add_to_cart_count,
    COUNT(CASE WHEN event_type = 'purchase' THEN 1 END) AS purchase_count,
    ROUND(
        CAST(COUNT(CASE WHEN event_type = 'add_to_cart' THEN 1 END) AS DOUBLE) / 
        NULLIF(COUNT(CASE WHEN event_type = 'page_view' THEN 1 END), 0) * 100, 
        2
    ) AS view_to_cart_rate_pct,
    ROUND(
        CAST(COUNT(CASE WHEN event_type = 'purchase' THEN 1 END) AS DOUBLE) / 
        NULLIF(COUNT(CASE WHEN event_type = 'add_to_cart' THEN 1 END), 0) * 100, 
        2
    ) AS cart_to_purchase_rate_pct
FROM capstone_aravi7_db.processed_events
WHERE product_id IS NOT NULL
GROUP BY product_id
ORDER BY view_count DESC
;

-- Query 2: Hourly Revenue
-- Total revenue by hour (price × quantity for purchases)
-- Business Question: What is our revenue pattern across hours?
SELECT 
    DATE_TRUNC('hour', timestamp) AS revenue_hour,
    ROUND(SUM(price * quantity), 2) AS total_revenue,
    COUNT(*) AS purchase_count,
    ROUND(AVG(price * quantity), 2) AS avg_order_value
FROM capstone_aravi7_db.processed_events
WHERE event_type = 'purchase'
GROUP BY DATE_TRUNC('hour', timestamp)
ORDER BY revenue_hour
;

-- Query 3: Top 10 Products
-- Most frequently viewed products with view counts
-- Business Question: Which products attract the most attention?
SELECT 
    product_id,
    category,
    COUNT(*) AS view_count
FROM capstone_aravi7_db.processed_events
WHERE event_type = 'page_view'
GROUP BY product_id, category
ORDER BY view_count DESC
LIMIT 10
;

-- Query 4: Category Performance
-- Daily event counts (all types) grouped by category
-- Business Question: How does engagement vary across product categories?
SELECT 
    category,
    event_date,
    COUNT(*) AS total_events,
    COUNT(CASE WHEN event_type = 'page_view' THEN 1 END) AS page_views,
    COUNT(CASE WHEN event_type = 'add_to_cart' THEN 1 END) AS add_to_carts,
    COUNT(CASE WHEN event_type = 'remove_from_cart' THEN 1 END) AS remove_from_carts,
    COUNT(CASE WHEN event_type = 'purchase' THEN 1 END) AS purchases
FROM capstone_aravi7_db.processed_events
WHERE category IS NOT NULL
GROUP BY category, event_date
ORDER BY event_date, category
;

-- Query 5: User Activity
-- Count of unique users and sessions per day
-- Business Question: How many unique users and sessions do we have daily?
SELECT 
    event_date,
    COUNT(DISTINCT user_id) AS unique_users,
    COUNT(DISTINCT session_id) AS unique_sessions,
    COUNT(*) AS total_events,
    ROUND(CAST(COUNT(*) AS DOUBLE) / COUNT(DISTINCT session_id), 2) AS events_per_session
FROM capstone_aravi7_db.processed_events
GROUP BY event_date
ORDER BY event_date
;
