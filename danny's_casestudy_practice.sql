## Danny's Dinner case study

use project_sql;

show tables;
desc members;
desc menu;
desc sales;

## 1. What is the total amount each customer spent at the restaurant?

select customer_id, sum(price) as total_amount_spent from sales inner join menu using(product_id) 
group by customer_id;

## 2. How many days has each customer visited the restaurant?

select customer_id, count(distinct(order_date)) as no_of_visits from sales group by customer_id;


## 3. What was the first item from the menu purchased by each customer?

select customer_id, product_name from (
select *, row_number() over( partition by customer_id order by order_date asc) as drnk from menu inner join sales 
using(product_id)) as t where drnk = 1;


## 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select product_name, count(product_name) as cnt from menu inner join sales using(product_id)
group by product_name order by cnt desc limit 1;

## 5. Which item was the most popular for each customer?

select * from (
select product_name,customer_id,count(*) as popular_item,  dense_rank() over(partition by customer_id order by count(*)) as drnk 
from menu inner join sales using(product_id)
group by product_name,customer_id) as t where drnk = 1;


## 6. Which item was purchased first by the customer after they became a member?

select * from (
select customer_id, product_name, order_date, join_date, row_number() over(partition by customer_id order by order_date asc) as rnk
from members inner join sales using(customer_id) inner join menu using(product_id)
where order_date > join_date) as t where rnk = 1;


## 7. Which item was purchased just before the customer became a member?

select * from (
select *, rank() over(partition by customer_id order by order_date desc) as rnk from members inner join sales 
using(customer_id) inner join menu using(product_id) 
where order_date  < join_date) as t where rnk = 1;


## 8. What is the total items and amount spent for each member before they became a member?

select customer_id, count(product_name) as total_items, sum(price) as amount_spent from menu inner join sales using(product_id) 
inner join members using(customer_id) where order_date < join_date
group by customer_id;


## 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

select customer_id, sum(case when product_name = "sushi" then price*20 else price*10 end) as points
 from sales inner join menu using(product_id)
 group by customer_id;

## 10. In the first week after a customer joins the program (including their join date) they 
## earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT 
    customer_id,
    SUM(CASE
        WHEN order_date BETWEEN join_date AND DATE_ADD(join_date, INTERVAL 6 DAY) THEN price * 20
        WHEN product_name = 'sushi' THEN price * 20
        ELSE price * 10
    END) AS points
FROM
    menu
        INNER JOIN
    sales USING (product_id)
        INNER JOIN
    members USING (customer_id)
WHERE
    order_date <= '2021-01-31'
GROUP BY customer_id;

