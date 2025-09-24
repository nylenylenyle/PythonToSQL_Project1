# End-to-End SQL + Python Project: Walmart Sales Analysis

## Project Overview
This project is an **end-to-end data analysis solution** built to demonstrate competency in **Python**, **SQL**, and working with **APIs**.  

The goal is to extract **critical business insights** from Walmart sales data. Python is used for **data processing and cleaning**, PostgreSQL and SQL for **advanced querying**, and the Kaggle API for **data acquisition**.

Q.1	How many orders were placed and items sold using each payment method?

Q.2	What are the highest rated categories at each Walmart branch?

Q.3	What are the busiest days of the week at each branch?

Q.4	Calculate the quantity of items sold per payment method

Q.5	What are the average, minimum, and maximum rating of each category in each city?

Q.6	What are the total profits for each category?

Q.7	What is the most common payment method at each branch?

Q.8	How many sales were made in the morning, afternoon, and evening?

Q.9	Which five branches saw the largest percentage decline in sales?


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
