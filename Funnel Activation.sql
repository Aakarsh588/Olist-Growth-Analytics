SELECT
 
 
 COUNT(order_purchase_timestamp) AS order_purchased,
 COUNT(order_approved_at) AS orders_approved,
 COUNT(order_delivered_carrier_date) AS orders_delivered,
 COUNT(order_delivered_customer_date) AS orders_recieved_by_customers
 
FROM `growth-marketing-509112.olist.Olist orders` 
