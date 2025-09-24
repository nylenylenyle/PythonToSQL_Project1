SELECT* FROM walmart
;

-- Q.1. How many orders were placed and items sold using each payment method?
SELECT
	payment_method,
	COUNT(*) AS order_count,
	SUM(quantity) AS qty_sold
FROM walmart
GROUP BY payment_method
;

-- Q.2 What are the highest rated categories at each Walmart branch? 
SELECT 
	branch,
	category,
	rating_avg
FROM
	(
	SELECT 
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank ,
		branch,
		category,
		AVG(rating)	AS rating_avg
	FROM walmart
	GROUP BY 2,3
	)
WHERE RANK = 1
;

-- Q.3 What are the busiest days of the week at each branch?
SELECT
	branch, 
	dayofweek,
	transactions
FROM(
	SELECT 
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*)) AS rank,
		branch, 
		TO_CHAR(TO_DATE(date, 'YYYY-MM-DD'), 'Day') AS dayofweek,
		COUNT(*) AS transactions
	FROM walmart
	GROUP BY 2,3
	)
WHERE rank = 1
;

-- Q.4 Calculate the quantity of items sold per payment method 
SELECT 
	payment_method,
	SUM(quantity) AS quantity_total
FROM walmart
GROUP BY 1
;

-- Q.5 What are the average, minimum, and maximum rating of each category in each city?

SELECT 
	city,
	payment_method,
	ROUND(AVG(rating)::NUMERIC,2) AS rating_avg,
	MIN(rating) AS rating_min,
	MAX(rating) AS rating_max
FROM walmart
GROUP BY 1,2
ORDER BY 1,2
;

-- Q.6 What are the total profits for each category?
SELECT
	 category,
	 ROUND(SUM(total * profit_margin)::NUMERIC,2) AS total_profit
FROM walmart
GROUP BY 1
ORDER BY 2 DESC
;

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
	Branch,
	CASE 
		WHEN EXTRACT(HOUR FROM time::time) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM time::time) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END day_time,
	COUNT(*) AS transactions
FROM walmart
GROUP BY 1,2
ORDER BY 1,2

-- Q.9 Which five branches saw the largest percentage decline in sales?
WITH 
revenue_2023
AS
	(
	SELECT
		branch,
		SUM(total) AS revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'YYY-MM-DD')) = 2023
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
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'YYY-MM-DD')) = 2022
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
WHERE (cs.revenue - ls.revenue) / ls.revenue < 0
ORDER BY 4 ASC 
LIMIT 5
;
