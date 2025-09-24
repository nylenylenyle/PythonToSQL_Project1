End-to-End SQL + Python Project: Walmart

## Project Overview

This project is an end-to-end data analysis solution designed to demonstrate competency in Python, SQL, and working with APIs. 

Our goal is to extract critical business insights from Walmart sales data. We will utilize Python for data processing and analysis and SQL for advanced querying.

---

## Walkthrough
### Installing Libraries and Configuring Kaggle API (Python)


```python
# Common libraries
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Additional packages to connect to Kaggle API
!pip install ipython-sql kaggle sqlalchemy psycopg2

# Database connectors
import psycopg2
from sqlalchemy import create_engine
```
```python
# This creates a hidden holder in home directory
# Necessary for connecting to Kaggle's API
!mkdir ~/.kaggle

```
```python
# Download from Kaggle
!kaggle datasets download -d najir0123/walmart-10k-sales-datasets -p {data_dir} --unzip
```
### Data Exploration (Python)

```python
# Store downloaded dataset to a data frame
df = pd.read_csv('/Users/nylehamidi/Documents/Research/portfolio_project2/{data_dir}/Walmart.csv', encoding_errors='ignore')
df.head()
```

```python
# Perform gut check 
# Check that counts are the same across all fields 
# Check that data types are appropriate 
df.info()
```

```python
# Check for NULLS
df.isnull().sum()
```

```python
# Check for duplicates 
df.duplicated().sum()
```

```python
# OBSERVATIONS:
# City and Branch are unnecessarily capitalized
# unit_price should be float
# quantity and unit_price are both missing 31 records
# 51 duplicates 
# Could create a datetime column using date and time columns
```
### Data Cleaning (Python)
```python
# Make all columns lowercase
df = df.rename(columns={
    "Branch": "branch",
    "City": "city"})
df.head()

# Could also use df.columns = df. columns.str.lower(), but I prefer specifying which columns to affect and how
```
```python
# Convert unit_price to float
# df['unit_price'].astype(float) does not work because of the '$'
# Remove '$', then convert to float
df['unit_price'].str.replace('$', '').astype(float)

# Replace data with '$' with new float values
df['unit_price'] = df['unit_price'].str.replace('$', '').astype(float)
df.info()
```

```python
# Drop or replace NULLS
# Without unit_price and quantity, incomplete records are not useful
# Drop NULLS
df.dropna(inplace=True)
df.isnull().sum()
```

```python
# Delete duplicates
df.drop_duplicates(inplace=True)
df.duplicated().sum()
```

```python
df["date"] = pd.to_datetime(df["date"], format="%d/%m/%y")
df["time"] = pd.to_datetime(df["time"], format="%H:%M:%S").dt.time
df.info()
# I'm unsure if this did anything, since I still had to specify time/date format in later SQL scripts
# df.info() did show that the date's datatype was datetime64[ns]
```

```python
# Later analysis would benefit from a column that calculates the dollar amount of each invoice/order
df['total'] = df['unit_price'] * df['quantity']
df.head()
```

```python
# Save cleaned, analysis-ready dataset
# This is more of a personal habit; I tend to keep various versions of my datasets 
df.to_csv("Walmart_Cleaned_Data.csv",index=False)

# Replace dataset with cleaned dataset
df = pd.read_csv('/Users/nylehamidi/Documents/Research/portfolio_project2/{data_dir}/Walmart_Cleaned_Data.csv', encoding_errors='ignore')
df.head()
```
### Connecting Python and Postgres (Python)

```python
engine_psql = create_engine("postgresql+psycopg2://postgres:password123@localhost:5432/project2")

try: 
    engine_psql
    print("connected")
except:
    print('no')
```

```python
df.to_sql(name='walmart', con=engine_psql, if_exists='append', index=False)
```

### Data Analysis (SQL)
#### Q.1. How many orders were placed and items sold using each payment method?
```sql
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
```









---

## Requirements

- **Python 3.8+**
- **SQL Databases**: MySQL, PostgreSQL
- **Python Libraries**:
  - `pandas`, `numpy`, `sqlalchemy`, `mysql-connector-python`, `psycopg2`
- **Kaggle API Key** (for data downloading)

## Getting Started

1. Clone the repository:
   ```bash
   git clone <repo-url>
   ```
2. Install Python libraries:
   ```bash
   pip install -r requirements.txt
   ```
3. Set up your Kaggle API, download the data, and follow the steps to load and analyze.

---

## Project Structure

```plaintext
|-- data/                     # Raw data and transformed data
|-- sql_queries/              # SQL scripts for analysis and queries
|-- notebooks/                # Jupyter notebooks for Python analysis
|-- README.md                 # Project documentation
|-- requirements.txt          # List of required Python libraries
|-- main.py                   # Main script for loading, cleaning, and processing data
```
---

## Results and Insights

This section will include your analysis findings:
- **Sales Insights**: Key categories, branches with highest sales, and preferred payment methods.
- **Profitability**: Insights into the most profitable product categories and locations.
- **Customer Behavior**: Trends in ratings, payment preferences, and peak shopping hours.

## Future Enhancements

Possible extensions to this project:
- Integration with a dashboard tool (e.g., Power BI or Tableau) for interactive visualization.
- Additional data sources to enhance analysis depth.
- Automation of the data pipeline for real-time data ingestion and analysis.

---

## License

This project is licensed under the MIT License. 

---

## Acknowledgments

- **Data Source**: Kaggle’s Walmart Sales Dataset
- **Inspiration**: Walmart’s business case studies on sales and supply chain optimization.

---
