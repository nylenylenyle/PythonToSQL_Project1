# Python to SQL Data Analysis with API Integration

## Project Overview
This project is an end-to-end data analysis solution built to demonstrate competency in Python, SQL, and working with APIs.  

The goal is to extract business insights from sales data. Python is used for data processing and cleaning, SQL for advanced querying, and the Kaggle API for data acquisition.

### Analysis will aim to address the following:

> ###### How many orders and items were sold by each payment method?  

> ###### Which categories received the highest ratings at each store?  

> ###### What are the busiest days of the week at each branch?  

> ###### How many items were sold by different payment methods?  

> ###### What are the average, minimum, and maximum ratings of each category in each city?  

> ###### What are the total profits (not revenue) for each category?  

> ###### What is the most common payment method at each branch?  

> ###### How many sales were made in the morning, afternoon, and evening?  

> ###### How many sales were made in the morning, afternoon, and evening at each store?  

> ###### Which five branches saw the largest percentage decline in sales?  


## Sample Code
### Python:
```python
# Convert unit_price to float
# df['unit_price'].astype(float) does not work because of the '$'
# Remove '$', then convert to float
df['unit_price'].str.replace('$', '').astype(float)

# Replace data with '$' with new float values
df['unit_price'] = df['unit_price'].str.replace('$', '').astype(float)
df.info()
```
### SQL
```sql
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

```


---

## Tools & Technologies
- **Python**: Pandas, NumPy, Matplotlib, Seaborn  
- **SQL**: PostgreSQL  
- **Other**: Kaggle API, SQLAlchemy, ipython-sql, psycopg2  
- **Environment**: Jupyter Notebook, DBeaver  

---

## Project Structure
```plaintext
walmart-sales-analysis/
├── README.md                  <- project overview (this file)
├── requirements.txt           <- Python dependencies
├── data/                      <- raw & cleaned datasets
├── notebooks/
│   └── analysis.ipynb         <- full Python data prep & EDA
├── sql_queries/
│   └── queries.sql            <- SQL analysis scripts
└── outputs/
    ├── Walmart_Cleaned_Data.csv
    └── charts/
        └── sales_by_branch.png
