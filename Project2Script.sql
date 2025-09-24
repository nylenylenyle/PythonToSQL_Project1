SELECT* FROM walmart;
-- Quick overview

-- Q.1. How many orders and items were sold by each payment method?
SELECT
	payment_method,
	COUNT(*) AS order_count,
	SUM(quantity) AS qty_sold
FROM walmart
GROUP BY payment_method
;

-- Q.2 Which categories recieved the highest ratings at each store?
SELECT 
	branch,
	category,
	rating_avg
FROM
	(
	SELECT 
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank,
		branch,
		category,
		AVG(rating)	AS rating_avg
	FROM walmart
	GROUP BY 2,3
	)
WHERE rank = 1
;
-- RANK() clause assigns a rank to each category in each store based on average ratings
-- Subquery alone does not accept 'WHERE rank = 1'

-- Q.3 What are the busiest days of the week at each branch?
SELECT
	branch, 
	day_of_week,
	transactions
FROM(
	SELECT 
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*)) AS rank,
		branch, 
		TO_CHAR(TO_DATE(date, 'YYYY-MM-DD'), 'Day') AS day_of_week,
		COUNT(*) AS transactions
	FROM walmart
	GROUP BY 2,3
	)
WHERE rank = 1
;
-- TO_DATE defines date format
-- TO_CHAR clause converts date into the day of the week as a string

-- Q.4 How many items were sold by different payment methods?
SELECT 
	payment_method,
	SUM(quantity) AS quantity_total
FROM walmart
GROUP BY 1
;

-- Q.5 What are the average, minimum, and maximum ratings of each category in each city?
SELECT 
	city,
	category,
	ROUND(AVG(rating)::NUMERIC,2) AS rating_avg,
	MIN(rating) AS rating_min,
	MAX(rating) AS rating_max
FROM walmart
GROUP BY 1,2
ORDER BY 1,2
;
-- ROUND() clause sometimes fails when argument includes calculations
-- '::NUMERIC' forces the values to be numeric datatype and bypasses this error 

-- Q.6 What are the total profits (not revenue) for each category?
SELECT
	 category,
	 ROUND(SUM(total * profit_margin)::NUMERIC,2) AS total_profit
FROM walmart
GROUP BY 1
ORDER BY 2 DESC
;
-- total is a calculated field (unit_price × quantity) created in Python in previous steps

-- Q.7 What is the most common payment method at each branch?
SELECT
	branch,
	payment_method,
	transactions
FROM (
	SELECT 
		branch,
		payment_method,
		COUNT(*) AS transactions,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*)) AS rank
	FROM walmart
	GROUP BY 1,2
	)
WHERE rank = 1
ORDER BY 1,2
;

-- Q.8 How many sales were made in the morning, afternoon, and evening?
SELECT
	CASE 
		WHEN EXTRACT(HOUR FROM time::time) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM time::time) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END day_time,
	COUNT(*) AS transactions
FROM walmart
GROUP BY 1
ORDER BY 1
;
-- EXTRACT() clause is similar to TO_CHAR() clause in Q.3 but value remains numeric 

-- Q.9 How many sales were made in the morning, afternoon, and evening at each store?
SELECT
	branch,
	CASE 
		WHEN EXTRACT(HOUR FROM time::time) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM time::time) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END day_time,
	COUNT(*) AS transactions
FROM walmart
GROUP BY 1,2
ORDER BY 1,2
;

-- Q.10 Which five branches saw the largest percentage decline in sales?
WITH 
revenue_2023
AS
	(
	SELECT
		branch,
		SUM(total) AS revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'YYYY-MM-DD')) = 2023
	GROUP BY 1
	)
,
revenue_2022
AS
	(
	SELECT
		branch,
		SUM(total) AS revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'YYYY-MM-DD')) = 2022
	GROUP BY 1
	)
SELECT 
	ls.branch,
	ls.revenue AS revenue_last_year,
	cs.revenue AS revenue_this_year,
	ROUND((((cs.revenue - ls.revenue) / ls.revenue)*100)::NUMERIC,2) AS revenue_delta_perc
FROM revenue_2022 AS ls
JOIN revenue_2023 AS cs
ON ls.branch = cs.branch
ORDER BY 4 ASC 
LIMIT 5
;
-- I used CTEs to separate 2022 and 2023 records grouped by branch
-- Then I joined the two tables on branch
-- The new table includes a calculated column showing percent change in revenue
-- Sorting by revenue delta and limiting to 5 records produces the 5 companies that experienced the largest sales decline

-- END -- 