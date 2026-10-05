WITH lifetime_value AS(

  SELECT 
   a.order_id,
   b.payment_value,
   c.customer_unique_id
  FROM `growth-marketing-509112.olist.Olist orders` AS a
  INNER JOIN `growth-marketing-509112.olist.Olist Payments` AS b ON a.order_id = b.order_id
  INNER JOIN `growth-marketing-509112.olist.Olist customers` AS c ON a.customer_id = c.customer_id
),

ltv AS(

SELECT 
 customer_unique_id,
 
 SUM(payment_value) AS LTV
FROM lifetime_value
GROUP BY customer_unique_id

),

purchase_rank AS (
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
)

SELECT 
 
 COUNT(*) AS Number_of_users,
 first_category,
 AVG(LTV) as avg_ltv
 

 FROM first_purchase_category AS aa
 JOIN ltv AS bb on aa.customer_unique_id = bb.customer_unique_id
 GROUP BY first_category
 