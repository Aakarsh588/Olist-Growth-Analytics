WITH orders_with_person AS (
  SELECT
    o.order_purchase_timestamp,
    c.customer_unique_id
  FROM `growth-marketing-509112.olist.Olist orders` AS o
  INNER JOIN `growth-marketing-509112.olist.Olist customers` AS c
    ON o.customer_id = c.customer_id
),

first_seen AS(


  SELECT 
   customer_unique_id,
   DATE_TRUNC(MIN(order_purchase_timestamp), MONTH) AS cohort_month
  FROM orders_with_person
  
  GROUP BY customer_unique_id

),

activity AS(
  SELECT 
   customer_unique_id,
   DATE_TRUNC(order_purchase_timestamp, MONTH) AS activity_month
  FROM orders_with_person 
  
  
  GROUP BY customer_unique_id,DATE_TRUNC(order_purchase_timestamp, MONTH) 
),

Retention_raw AS(


SELECT 
  COUNT(a.customer_unique_id) AS number_of_users,
  DATE_DIFF(DATE(b.activity_month), DATE(a.cohort_month), MONTH) AS month_number,
  a.cohort_month,
  
 FROM first_seen AS a
 INNER JOIN activity AS b ON a.customer_unique_id = b.customer_unique_id
 WHERE a.cohort_month BETWEEN TIMESTAMP('2017-01-01') AND TIMESTAMP('2018-08-01')
 GROUP BY month_number, a.cohort_month
 ORDER BY a.cohort_month, month_number ASC
)

SELECT
  cohort_month,
  month_number,
  number_of_users,
  MAX(CASE WHEN month_number = 0 THEN number_of_users END) OVER (PARTITION BY cohort_month) AS cohort_size,
  ROUND(number_of_users / MAX(CASE WHEN month_number = 0 THEN number_of_users END) OVER (PARTITION BY cohort_month) * 100, 2) AS retention_pct
FROM retention_raw
ORDER BY cohort_month, month_number
