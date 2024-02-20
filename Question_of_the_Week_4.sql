-- For each brand, which month in 2020 had the highest number of refunds, and how many refunds did that month have?
   
    -- Step 1) Clean product names & Create brands.
    -- Step 2) Wrap Step 1 query in CTE and use a window function to return the month where 'max' refunds occurred per brand
SELECT DISTINCT product_name FROM core.orders;

SELECT
    DATE_TRUNC(refund_ts, month) as month_2020,
    COUNT(refund_ts) as refund_count
FROM `core.order_status`
WHERE EXTRACT(year from refund_ts) = 2020
GROUP BY 1
ORDER BY 1;
-- refunds only occurred in November (2) & December (27) in 2020

WITH refund_2020 AS (
SELECT
    DATE_TRUNC(refund_ts, month) as refund_month,
    CASE 
        WHEN product_name LIKE ANY ('Apple%', 'Macbook%') THEN 'Apple'
        WHEN product_name LIKE ('Samsung%') THEN 'Samsung'
        WHEN product_name LIKE ('bose%') THEN 'Bose'
        WHEN product_name LIKE ('ThinkPad%') THEN 'Thinkpad'
        ELSE 'unknown' 
    END AS brand,
    COUNT(refund_ts) AS refund_count
FROM core.orders
JOIN core.order_status
    ON orders.id = order_status.order_id
WHERE EXTRACT(year from refund_ts) = 2020
GROUP BY 1,2
ORDER BY 1
)

SELECT
    brand,
    refund_month,
    refund_count
FROM refund_2020
QUALIFY ROW_NUMBER() OVER(PARTITION BY brand ORDER BY refund_count DESC) = 1 
ORDER BY 3 DESC
; 
