SELECT 
 COUNT (DISTINCT a.order_id) AS total_orders,
 SUM(payment_value) AS total_value,
 ROUND(SUM(payment_value)/COUNT( DISTINCT a.order_id), 2) AS AOV,
 payment_type,
 product_category_name

  


FROM `growth-marketing-509112.olist.Olist order items`  AS a
INNER JOIN `growth-marketing-509112.olist.Olist Payments` AS b 
ON a.order_id = b.order_id
INNER JOIN `growth-marketing-509112.olist.Olist_products` AS c 
ON a.product_id = c.product_id

GROUP BY payment_type,product_category_name
ORDER BY AOV DESC