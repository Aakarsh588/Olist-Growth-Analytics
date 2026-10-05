WITH purchase_rank AS (
  SELECT
    c.customer_unique_id,
    o.order_id,
    ROW_NUMBER() OVER (PARTITION BY c.customer_unique_id ORDER BY o.order_purchase_timestamp) AS order_rank
  FROM `growth-marketing-509112.olist.Olist orders` AS o
  INNER JOIN `growth-marketing-509112.olist.Olist customers` AS c ON o.customer_id = c.customer_id
),

first_order_items AS (
  SELECT
    oi.order_id,
    p.product_category_name,
    ROW_NUMBER() OVER (PARTITION BY oi.order_id ORDER BY oi.product_id) AS item_rank
  FROM `growth-marketing-509112.olist.Olist order items` AS oi
  INNER JOIN `growth-marketing-509112.olist.Olist_products` AS p ON oi.product_id = p.product_id
),

first_purchase_category AS (
  SELECT
    pr.customer_unique_id,
    foi.product_category_name AS first_category
  FROM purchase_rank AS pr
  INNER JOIN first_order_items AS foi ON pr.order_id = foi.order_id
  WHERE pr.order_rank = 1
    AND foi.item_rank = 1
),

ever_returned AS (
  SELECT
    customer_unique_id,
    MAX(CASE WHEN order_rank > 1 THEN 1 ELSE 0 END) AS returned
  FROM purchase_rank
  GROUP BY customer_unique_id
)

SELECT
  fpc.first_category,
  COUNT(*) AS total_customers,
  SUM(er.returned) AS customers_who_returned,
  ROUND(SUM(er.returned) / COUNT(*) * 100, 2) AS return_rate_pct
FROM first_purchase_category AS fpc
INNER JOIN ever_returned AS er ON fpc.customer_unique_id = er.customer_unique_id
GROUP BY fpc.first_category
HAVING COUNT(*) > 200
ORDER BY return_rate_pct DESC