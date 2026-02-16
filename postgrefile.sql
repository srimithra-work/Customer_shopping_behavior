DROP TABLE IF EXISTS cust_shopping_behavior;
CREATE TABLE cust_shopping_behavior (
    customer_id INT PRIMARY KEY,
    age INT,
    gender VARCHAR(10),
    item_purchased VARCHAR(200),
    category VARCHAR(100),
    purchase_amount_usd NUMERIC(10,2),
    location VARCHAR(100),
    size VARCHAR(20),
    color VARCHAR(50),
    season VARCHAR(50),
    review_rating NUMERIC(4,2),
    subscription_status VARCHAR(10),
    discount_applied VARCHAR(10),
    previous_purchases INT,
    payment_method VARCHAR(50),
    frequency_of_purchases VARCHAR(50)
);
\copy cust_shopping_behavior(customer_id, age, gender, item_purchased, category, purchase_amount_usd,
                             location, size, color, season, review_rating,
                             subscription_status, discount_applied, previous_purchases,
                             payment_method, frequency_of_purchases)
FROM 'C:/Users/yarra/Downloads/cust_shopping_behavior.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');



SELECT COUNT(*) FROM cust_shopping_behavior;
SELECT * FROM cust_shopping_behavior LIMIT 10;

--total revenue generated across demogrpahics(male vs. female)?
select sum(purchase_amount_usd) as revenue, gender from cust_shopping_behavior group by gender;



--which customers used discount but still spent more than the avg purchase amount?
select customer_id, purchase_amount_usd  from cust_shopping_behavior 
where discount_applied= '"Yes"' and purchase_amount_usd>=(
	select avg(purchase_amount_usd) as avg_purchase_amount from cust_shopping_behavior
);

--which are the top 5 products with the highest average review rating?
select item_purchased, round(avg(review_rating), 2) as avg_rr from cust_shopping_behavior
group by item_purchased
order by avg_rr desc
limit 5;

--Do subscribed customers spend more? Compare avg spend and total revenue between subscribers and non-subscribers
select count(customer_id) as total_customers, subscription_status, 
round(avg(purchase_Amount_usd), 2) as avg_spend, round(sum(purchase_amount_usd), 2) as total_revenue
from cust_shopping_behavior
group by subscription_status
order by total_revenue, avg_spend desc;

--which 5 products has the highest percentages of purchases with the discounts applied
select item_purchased, 
round(100* sum(case when discount_applied='"yes"' then 1 else 0 end)/count(*), 2) as discount_rate
from cust_shopping_behavior
group by item_purchased
order by discount_rate desc limit 5;

--segment customers into new, returning, loyal based on their total no of previous purchases
--and show the count of each segment
with customer_type as (
select customer_id, previous_purchases, 
case 
	when previous_purchases=1 then 'new'
	when previous_purchases between 2 and 10 then 'returning'
	when previous_purchases >10 then 'loyal'
	end as customer_segment
from cust_shopping_behavior
)
select customer_segment, count(*) as "no of customers"
from customer_type
group by customer_segment;

--top 3 purchased products within each category
with item_counts as(
select category, item_purchased, count(customer_id)as total_orders, 
row_number() over(partition by category order by count(customer_id) desc) as item_rank
from cust_shopping_behavior 
group by category, item_purchased
)
select item_rank, category, item_purchased, total_orders from item_counts
where item_rank<=3;

--are customers who are repeat buyers(>5 previous_purchases) also likely to be subscribers?
select subscription_status, count(customer_id) as repeat_customers 
from cust_shopping_behavior 
where previous_purchases>5
group by subscription_status;

--whats the revenue contribution of each age group?
select age, sum(purchase_amount_usd) as total_revenue
from cust_shopping_behavior
group by age
order by total_revenue desc limit 10;
	


