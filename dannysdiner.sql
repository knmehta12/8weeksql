--8 Week SQL Challenge 

 --DANNY’S DINNER 

--1. What is the total amount each customer spent at the restaurant?

SELECT
SUM(m.price) as price_percustomer, s.customer_id
FROM dannys_diner.menu m 
JOIN  dannys_diner.sales s
ON m.product_id=s.product_id
GROUP BY s.customer_id;



--2. How many days has each customer visited the restaurant?

SELECT
customer_id, COUNT( DISTINCT order_date)
FROM dannys_diner.sales  
GROUP BY customer_id;





--3. What was the first item from the menu purchased by each customer?
SELECT
 DISTINCT customer_id, LEFT(CAST(MIN(order_date)  as varchar), 10) as first_time_entrance
FROM dannys_diner.sales 
GROUP BY customer_id;




----4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT COUNT(sales.product_id), sales.customer_id, menu.product_name
 FROM dannys_diner.sales
 JOIN dannys_diner.menu ON
 	sales.product_id = menu.product_id
 WHERE sales.product_id = 
 (SELECT a.product_id 
 FROM (SELECT product_id, COUNT(product_id) 
          FROM  dannys_diner.sales   
          GROUP BY product_id
          ORDER BY COUNT(product_id) DESC 
LIMIT 1 )
 	as a)
GROUP BY sales.customer_id, menu.product_name; 

 

/* Find Max Count without using max , Find id for that max count and run query on that.  
*/




--5. Which item was the most popular for each customer?

SELECT product_id , max, m.customer_id
 FROM (
 SELECT MAX(y.total) as max, customer_id 
FROM
 (SELECT
  	COUNT(product_id) as total , product_id, 
    	customer_id 
FROM dannys_diner.sales
GROUP BY customer_id , product_id ) as y 
GROUP BY customer_id )  as m
JOIN dannys_diner.sales ON m.customer_id= sales.customer_id
GROUP BY sales.product_id, m.max,m.customer_id, sales.customer_id
HAVING COUNT(sales.product_id) = m.max 
AND sales.customer_id=m.customer_id ;




--6. Which item was purchased first by the customer after they became a member?
SELECT LEFT(CAST(MIN(y.order_date) as varchar),10) as first_order, y.customer_id
FROM(
SELECT
  s.order_date, m.customer_id
FROM dannys_diner.sales s JOIN
dannys_diner.members m 
ON m.customer_id = s.customer_id 
WHERE s.order_date > m.join_date
GROUP BY m.customer_id, s.order_date
ORDER BY s.order_date) as y
GROUP BY y.customer_id ;



--7. Which item was purchased just before the customer became a member?
SELECT LEFT(CAST(MAX(y.order_date) as varchar),10) as first_order_before, y.customer_id
FROM(
SELECT
  s.order_date, m.customer_id
FROM dannys_diner.sales s JOIN
dannys_diner.members m 
ON m.customer_id = s.customer_id 
WHERE s.order_date < m.join_date
GROUP BY m.customer_id, s.order_date
ORDER BY s.order_date) as y
GROUP BY y.customer_id;


--9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT customer_id, SUM(total_points)*10 as points
FROM (SELECT  customer_id , s.product_id , 
CASE WHEN s.product_id=1 THEN SUM(price)*2
 WHEN s.product_id <> 1 THEN SUM(price)
END  AS total_points
FROM dannys_diner.sales s JOIN dannys_diner.menu m
ON s.product_id = m.product_id
GROUP BY customer_id, m.product_id, s.product_id) as y
GROUP BY customer_id ;



--15. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT customer_id,  SUM(total_points)
FROM (
SELECT  customer_id  , order_date, y.week, 
CASE 
  WHEN  y.week = 'Week1' THEN SUM(me.price)*2 
  WHEN y.product_id =1 AND y.week ='Not' THEN SUM(me.price)*2 
  WHEN y.product_id <> 1 AND y.week ='Not' THEN SUM(me.price) 
  END as total_points
FROM (
SELECT order_date , s.customer_id, product_id, 
CASE 
	WHEN order_date BETWEEN join_date AND join_date + 6
    THEN 'Week1'
    ELSE 'Not'
    END AS week
 FROM dannys_diner.sales s JOIN  dannys_diner.members m
ON s.customer_id = m.customer_id
)  y 
 JOIN 
 dannys_diner.menu me ON
 y.product_id = me.product_id
 WHERE order_date BETWEEN '2021-01-01' AND '2021-01-31'
 GROUP BY y.customer_id, y.order_date,y.product_id, y.week
  ) as kk
  GROUP BY customer_id;
Output:




