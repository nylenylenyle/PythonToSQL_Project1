# Python to SQL Data Analysis with API Integration

## Project Overview
This project is an end-to-end data analysis solution designed to demonstrate competency in Python, SQL, and working with APIs.  

The goal is to extract commonly requested business insights from a dataset accessed via an API. Python is used for data processing and cleaning, SQL for advanced querying, and the Kaggle API for data acquisition.

### Analysis will aim to address the following questions:

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
### SQL:
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

## Results and Insights

- Credit cards were the preferred payment method and out-sold other methods in both number of items sold and orders placed.
- Categories 'Food & Beverages' and 'Health & Beauty' ranked highest in customer ratings at multiple branches, suggesting strong consumer demand and satisfaction in these areas.
- When factoring in profit margins, categories 'Electronics' and 'Home & Lifestyle' emerged as the most profitable, even though they did not always drive the largest sales volume.
- Analysis of transaction timestamps revealed that most sales occurred in the afternoon and evening, with fewer transactions in the morning.  
- Some branches had an unusually large number of orders placed through an e-wallet.


---

## Tools & Libraries
- **Python**: Pandas, NumPy, Matplotlib, Seaborn  
- **SQL**: PostgreSQL  
- **Other**: Kaggle API, SQLAlchemy, ipython-sql, psycopg2  
- **Environment**: Jupyter Notebook, DBeaver  

---

## Requirements

- **Python 3.8+**
- **SQL Databases**: MySQL, PostgreSQL
- **Python Libraries**:
  - `pandas`, `numpy`, `sqlalchemy`, `mysql-connector-python`, `psycopg2`
- **Kaggle API Key** (for data downloading)


---

## Project Structure
```plaintext
PyhthonToSQL_Project2
├── README.md                  <- project overview (this file)
├── data/                      <- raw & cleaned datasets
│   ├── Walmart_Cleaned_Data.csv
│   └── Walmart.csv
├── notebooks/
│   └── Project2Notebook.ipynb <- Python data exploration & cleaning with comments
└── sql_queries/
    └── Project2Script.sql     <- SQL analysis with comments
