-- Monday Coffee -- Data Analysis 

SELECT * FROM city;
SELECT * FROM products;
SELECT * FROM customers;
SELECT * FROM sales;

-- Reports & Data Analysis


-- Q.1 Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?


select city_name, round(population * 0.25/1000000, 2) as Cust_in_mil
from city
order by 2 desc;

-- -- Q.2
-- Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?


select city_name, sum(total) as revenue
from sales as s
join customers as c
on s.customer_id = c.customer_id
join city as ci
on ci.city_id = c.city_id
where extract(year from sale_date) = 2023
and extract(quarter from sale_date) = 4
group by 1
order by 2 desc;


-- Q.3
-- Sales Count for Each Product
-- How many units of each coffee product have been sold?

select product_name, count(*)
from products as p 
left join sales as s
on s.product_id = p.product_id
group by 1
order by 2 desc;

-- Q.4
-- Average Sales Amount per City
-- What is the average sales amount per customer in each city?

-- city abd total sale
-- no cx in each these city


select city_name, sum(total) as revenue, count(distinct s.customer_id) as unique_cust,
round(sum(total)::numeric/count(distinct s.customer_id)::numeric, 2) as avg_sale_per_cust
from sales as s
join customers as c
on s.customer_id = c.customer_id
join city as ci
on ci.city_id = c.city_id
group by 1
order by 4 desc;


-- -- Q.5
-- City Population and Coffee Consumers (25%)
-- Provide a list of cities along with their populations and estimated coffee consumers.
-- return city_name, total current cx, estimated coffee consumers (25%)

select city_name, round(population * 0.25/1000000, 2) as Cust_in_mil,
count(distinct s.customer_id) as unique_cust
from sales as s
join customers as c
on s.customer_id = c.customer_id
join city as ci
on ci.city_id = c.city_id
group by 1, 2
order by 2 desc;


-- -- Q6
-- Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?

select * from
(select city_name, product_name, count(s.product_id),
dense_rank() over(partition by city_name order by count(s.product_id) desc) as top_prod
from products as p 
left join sales as s
on s.product_id = p.product_id
join customers as c
on c.customer_id = s.customer_id
join city as ci
on ci.city_id = c.city_id
group by 1, 2
order by 1, 3 desc)
where top_prod <= 3;


-- Q.7
-- Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?

select city_name, count(distinct s.customer_id) as unique_cust
from sales as s
join customers as c
on s.customer_id = c.customer_id
join city as ci
on ci.city_id = c.city_id
where product_id in (1,2,3,4,5,6,7,8,9,10,11,12,13,14)
group by 1
order by 2 desc;


-- -- Q.8
-- Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer

-- Conclusions

select city_name, sum(total) as revenue, count(distinct s.customer_id) as unique_cust,
round(sum(total)::numeric/count(distinct s.customer_id)::numeric, 2) as avg_sale_per_cust,
estimated_rent,
round(estimated_rent::numeric/count(distinct s.customer_id)::numeric, 2) as avg_rent_per_cust
from sales as s
join customers as c
on s.customer_id = c.customer_id
join city as ci
on ci.city_id = c.city_id
group by 1, 5
order by 4 desc;


-- Q.9
-- Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly)
-- by each city

with new_table as
(select city_name, extract(year from sale_date) as year, extract(month from sale_date) as month, sum(total) as curr_sale,
lag(sum(total), 1) over() as prev_sale
from sales as s
join customers as c
on s.customer_id = c.customer_id
join city as ci
on ci.city_id = c.city_id
group by 1, 2, 3
order by 2, 1, 3)
select *, 
round((curr_sale-prev_sale)::numeric/prev_sale::numeric * 100, 2) as growth_rate
from new_table
where prev_sale is not null;	


-- Q.10
-- Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer



select city_name, sum(total) as revenue, count(distinct s.customer_id) as unique_cust,
round(population * 0.25/1000000, 2) as Cust_in_mil,
round(sum(total)::numeric/count(distinct s.customer_id)::numeric, 2) as avg_sale_per_cust,
estimated_rent,
round(estimated_rent::numeric/count(distinct s.customer_id)::numeric, 2) as avg_rent_per_cust
from sales as s
join customers as c
on s.customer_id = c.customer_id
join city as ci
on ci.city_id = c.city_id
group by 1,4,6
order by 2 desc;

/*
-- Recomendation
City 1: Pune
	1.Average rent per customer is very low.
	2.Highest total revenue.
	3.Average sales per customer is also high.

City 2: Delhi
	1.Highest estimated coffee consumers at 7.7 million.
	2.Highest total number of customers, which is 68.
	3.Average rent per customer is 330 (still under 500).

City 3: Jaipur
	1.Highest number of customers, which is 69.
	2.Average rent per customer is very low at 156.
	3.Average sales per customer is better at 11.6k.



