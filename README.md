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





EXAMPLES OF CODE:
PYTHON
SQL

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
