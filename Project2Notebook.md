Installing Libraries and Configuring Kaggle API


```python
# Common libraries 
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
```


```python
# Additional packages to connect to Kaggle API
!pip install ipython-sql kaggle sqlalchemy psycopg2
```


```python
# Database connectors
import psycopg2
```


```python
from sqlalchemy import create_engine
```


```python
# This creates a hidden holder in home directory
# Necessary for connecting to Kaggle's API
!mkdir ~/.kaggle
```


```python
# Download from Kaggle's API
!kaggle datasets download -d najir0123/walmart-10k-sales-datasets -p {data_dir} --unzip
```

    Warning: Your Kaggle API key is readable by other users on this system! To fix this, you can run 'chmod 600 /Users/nylehamidi/.kaggle/kaggle.json'
    Dataset URL: https://www.kaggle.com/datasets/najir0123/walmart-10k-sales-datasets
    License(s): MIT
    Downloading walmart-10k-sales-datasets.zip to {data_dir}
      0%|                                                | 0.00/143k [00:00<?, ?B/s]
    100%|█████████████████████████████████████████| 143k/143k [00:00<00:00, 175MB/s]


Data Exploration


```python
# Store downloaded dataset to a data frame
df = pd.read_csv('/Users/nylehamidi/Documents/Research/portfolio_project2/{data_dir}/Walmart.csv', encoding_errors='ignore')
df.head()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>invoice_id</th>
      <th>Branch</th>
      <th>City</th>
      <th>category</th>
      <th>unit_price</th>
      <th>quantity</th>
      <th>date</th>
      <th>time</th>
      <th>payment_method</th>
      <th>rating</th>
      <th>profit_margin</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1</td>
      <td>WALM003</td>
      <td>San Antonio</td>
      <td>Health and beauty</td>
      <td>$74.69</td>
      <td>7.0</td>
      <td>05/01/19</td>
      <td>13:08:00</td>
      <td>Ewallet</td>
      <td>9.1</td>
      <td>0.48</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2</td>
      <td>WALM048</td>
      <td>Harlingen</td>
      <td>Electronic accessories</td>
      <td>$15.28</td>
      <td>5.0</td>
      <td>08/03/19</td>
      <td>10:29:00</td>
      <td>Cash</td>
      <td>9.6</td>
      <td>0.48</td>
    </tr>
    <tr>
      <th>2</th>
      <td>3</td>
      <td>WALM067</td>
      <td>Haltom City</td>
      <td>Home and lifestyle</td>
      <td>$46.33</td>
      <td>7.0</td>
      <td>03/03/19</td>
      <td>13:23:00</td>
      <td>Credit card</td>
      <td>7.4</td>
      <td>0.33</td>
    </tr>
    <tr>
      <th>3</th>
      <td>4</td>
      <td>WALM064</td>
      <td>Bedford</td>
      <td>Health and beauty</td>
      <td>$58.22</td>
      <td>8.0</td>
      <td>27/01/19</td>
      <td>20:33:00</td>
      <td>Ewallet</td>
      <td>8.4</td>
      <td>0.33</td>
    </tr>
    <tr>
      <th>4</th>
      <td>5</td>
      <td>WALM013</td>
      <td>Irving</td>
      <td>Sports and travel</td>
      <td>$86.31</td>
      <td>7.0</td>
      <td>08/02/19</td>
      <td>10:37:00</td>
      <td>Ewallet</td>
      <td>5.3</td>
      <td>0.48</td>
    </tr>
  </tbody>
</table>
</div>




```python
# Perform gut check 
# Check that counts are the same across all fields 
# Check that data types are appropriate 
df.info()
```

    <class 'pandas.core.frame.DataFrame'>
    RangeIndex: 10051 entries, 0 to 10050
    Data columns (total 11 columns):
     #   Column          Non-Null Count  Dtype  
    ---  ------          --------------  -----  
     0   invoice_id      10051 non-null  int64  
     1   Branch          10051 non-null  object 
     2   City            10051 non-null  object 
     3   category        10051 non-null  object 
     4   unit_price      10020 non-null  object 
     5   quantity        10020 non-null  float64
     6   date            10051 non-null  object 
     7   time            10051 non-null  object 
     8   payment_method  10051 non-null  object 
     9   rating          10051 non-null  float64
     10  profit_margin   10051 non-null  float64
    dtypes: float64(3), int64(1), object(7)
    memory usage: 863.9+ KB



```python
# Check for NULLS
df.isnull().sum()
```




    invoice_id         0
    Branch             0
    City               0
    category           0
    unit_price        31
    quantity          31
    date               0
    time               0
    payment_method     0
    rating             0
    profit_margin      0
    dtype: int64




```python
# Check for duplicates 
df.duplicated().sum()
```




    51



Data Cleaning


```python
# OBSERVATIONS
# City and Branch are unnecessarily capitalized
# unit_price should be float
# quantity and unit_price are both missing 31 records
# 51 duplicates 
# Could create a datetime column using date and time columns
```


```python
# Make all columns lowercase
df = df.rename(columns={
    "Branch": "branch",
    "City": "city"})
df.head()

# Could also use df.columns = df. columns.str.lower(), but I prefer specifying which columns to affect and how
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>invoice_id</th>
      <th>branch</th>
      <th>city</th>
      <th>category</th>
      <th>unit_price</th>
      <th>quantity</th>
      <th>date</th>
      <th>time</th>
      <th>payment_method</th>
      <th>rating</th>
      <th>profit_margin</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1</td>
      <td>WALM003</td>
      <td>San Antonio</td>
      <td>Health and beauty</td>
      <td>$74.69</td>
      <td>7.0</td>
      <td>05/01/19</td>
      <td>13:08:00</td>
      <td>Ewallet</td>
      <td>9.1</td>
      <td>0.48</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2</td>
      <td>WALM048</td>
      <td>Harlingen</td>
      <td>Electronic accessories</td>
      <td>$15.28</td>
      <td>5.0</td>
      <td>08/03/19</td>
      <td>10:29:00</td>
      <td>Cash</td>
      <td>9.6</td>
      <td>0.48</td>
    </tr>
    <tr>
      <th>2</th>
      <td>3</td>
      <td>WALM067</td>
      <td>Haltom City</td>
      <td>Home and lifestyle</td>
      <td>$46.33</td>
      <td>7.0</td>
      <td>03/03/19</td>
      <td>13:23:00</td>
      <td>Credit card</td>
      <td>7.4</td>
      <td>0.33</td>
    </tr>
    <tr>
      <th>3</th>
      <td>4</td>
      <td>WALM064</td>
      <td>Bedford</td>
      <td>Health and beauty</td>
      <td>$58.22</td>
      <td>8.0</td>
      <td>27/01/19</td>
      <td>20:33:00</td>
      <td>Ewallet</td>
      <td>8.4</td>
      <td>0.33</td>
    </tr>
    <tr>
      <th>4</th>
      <td>5</td>
      <td>WALM013</td>
      <td>Irving</td>
      <td>Sports and travel</td>
      <td>$86.31</td>
      <td>7.0</td>
      <td>08/02/19</td>
      <td>10:37:00</td>
      <td>Ewallet</td>
      <td>5.3</td>
      <td>0.48</td>
    </tr>
  </tbody>
</table>
</div>




```python
# Convert unit_price to float
# df['unit_price'].astype(float) does not work because of the '$'
# Remove '$', then convert to float
df['unit_price'].str.replace('$', '').astype(float)

# Replace data with '$' with new float values
df['unit_price'] = df['unit_price'].str.replace('$', '').astype(float)
df.info()
```

    <class 'pandas.core.frame.DataFrame'>
    RangeIndex: 10051 entries, 0 to 10050
    Data columns (total 11 columns):
     #   Column          Non-Null Count  Dtype  
    ---  ------          --------------  -----  
     0   invoice_id      10051 non-null  int64  
     1   branch          10051 non-null  object 
     2   city            10051 non-null  object 
     3   category        10051 non-null  object 
     4   unit_price      10020 non-null  float64
     5   quantity        10020 non-null  float64
     6   date            10051 non-null  object 
     7   time            10051 non-null  object 
     8   payment_method  10051 non-null  object 
     9   rating          10051 non-null  float64
     10  profit_margin   10051 non-null  float64
    dtypes: float64(4), int64(1), object(6)
    memory usage: 863.9+ KB



```python
# Drop or replace NULLS
# Without unit_price and quantity, incomplete records are not useful
# Drop NULLS
df.dropna(inplace=True)
df.isnull().sum()
```




    invoice_id        0
    branch            0
    city              0
    category          0
    unit_price        0
    quantity          0
    date              0
    time              0
    payment_method    0
    rating            0
    profit_margin     0
    dtype: int64




```python
# Delete duplicates
df.drop_duplicates(inplace=True)
df.duplicated().sum()
```




    0




```python
df["date"] = pd.to_datetime(df["date"], format="%d/%m/%y")
df["time"] = pd.to_datetime(df["time"], format="%H:%M:%S").dt.time
df.info()
```

    <class 'pandas.core.frame.DataFrame'>
    Index: 9969 entries, 0 to 9999
    Data columns (total 11 columns):
     #   Column          Non-Null Count  Dtype         
    ---  ------          --------------  -----         
     0   invoice_id      9969 non-null   int64         
     1   branch          9969 non-null   object        
     2   city            9969 non-null   object        
     3   category        9969 non-null   object        
     4   unit_price      9969 non-null   float64       
     5   quantity        9969 non-null   float64       
     6   date            9969 non-null   datetime64[ns]
     7   time            9969 non-null   object        
     8   payment_method  9969 non-null   object        
     9   rating          9969 non-null   float64       
     10  profit_margin   9969 non-null   float64       
    dtypes: datetime64[ns](1), float64(4), int64(1), object(5)
    memory usage: 934.6+ KB



```python
# Later analysis would benefit from a column that calculates the dollar amount of each invoice/order
df['total'] = df['unit_price'] * df['quantity']
df.head()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>invoice_id</th>
      <th>branch</th>
      <th>city</th>
      <th>category</th>
      <th>unit_price</th>
      <th>quantity</th>
      <th>date</th>
      <th>time</th>
      <th>payment_method</th>
      <th>rating</th>
      <th>profit_margin</th>
      <th>total</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1</td>
      <td>WALM003</td>
      <td>San Antonio</td>
      <td>Health and beauty</td>
      <td>74.69</td>
      <td>7.0</td>
      <td>2019-01-05</td>
      <td>13:08:00</td>
      <td>Ewallet</td>
      <td>9.1</td>
      <td>0.48</td>
      <td>522.83</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2</td>
      <td>WALM048</td>
      <td>Harlingen</td>
      <td>Electronic accessories</td>
      <td>15.28</td>
      <td>5.0</td>
      <td>2019-03-08</td>
      <td>10:29:00</td>
      <td>Cash</td>
      <td>9.6</td>
      <td>0.48</td>
      <td>76.40</td>
    </tr>
    <tr>
      <th>2</th>
      <td>3</td>
      <td>WALM067</td>
      <td>Haltom City</td>
      <td>Home and lifestyle</td>
      <td>46.33</td>
      <td>7.0</td>
      <td>2019-03-03</td>
      <td>13:23:00</td>
      <td>Credit card</td>
      <td>7.4</td>
      <td>0.33</td>
      <td>324.31</td>
    </tr>
    <tr>
      <th>3</th>
      <td>4</td>
      <td>WALM064</td>
      <td>Bedford</td>
      <td>Health and beauty</td>
      <td>58.22</td>
      <td>8.0</td>
      <td>2019-01-27</td>
      <td>20:33:00</td>
      <td>Ewallet</td>
      <td>8.4</td>
      <td>0.33</td>
      <td>465.76</td>
    </tr>
    <tr>
      <th>4</th>
      <td>5</td>
      <td>WALM013</td>
      <td>Irving</td>
      <td>Sports and travel</td>
      <td>86.31</td>
      <td>7.0</td>
      <td>2019-02-08</td>
      <td>10:37:00</td>
      <td>Ewallet</td>
      <td>5.3</td>
      <td>0.48</td>
      <td>604.17</td>
    </tr>
  </tbody>
</table>
</div>




```python
# Save cleaned, analysis-ready dataset  
df.to_csv("Walmart_Cleaned_Data.csv",index=False)
```


```python
# Replace dataset with cleaned dataset
df = pd.read_csv('/Users/nylehamidi/Documents/Research/portfolio_project2/{data_dir}/Walmart_Cleaned_Data.csv', encoding_errors='ignore')
df.head()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>invoice_id</th>
      <th>branch</th>
      <th>city</th>
      <th>category</th>
      <th>unit_price</th>
      <th>quantity</th>
      <th>date</th>
      <th>time</th>
      <th>payment_method</th>
      <th>rating</th>
      <th>profit_margin</th>
      <th>total</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1</td>
      <td>WALM003</td>
      <td>San Antonio</td>
      <td>Health and beauty</td>
      <td>74.69</td>
      <td>7.0</td>
      <td>2019-01-05</td>
      <td>13:08:00</td>
      <td>Ewallet</td>
      <td>9.1</td>
      <td>0.48</td>
      <td>522.83</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2</td>
      <td>WALM048</td>
      <td>Harlingen</td>
      <td>Electronic accessories</td>
      <td>15.28</td>
      <td>5.0</td>
      <td>2019-03-08</td>
      <td>10:29:00</td>
      <td>Cash</td>
      <td>9.6</td>
      <td>0.48</td>
      <td>76.40</td>
    </tr>
    <tr>
      <th>2</th>
      <td>3</td>
      <td>WALM067</td>
      <td>Haltom City</td>
      <td>Home and lifestyle</td>
      <td>46.33</td>
      <td>7.0</td>
      <td>2019-03-03</td>
      <td>13:23:00</td>
      <td>Credit card</td>
      <td>7.4</td>
      <td>0.33</td>
      <td>324.31</td>
    </tr>
    <tr>
      <th>3</th>
      <td>4</td>
      <td>WALM064</td>
      <td>Bedford</td>
      <td>Health and beauty</td>
      <td>58.22</td>
      <td>8.0</td>
      <td>2019-01-27</td>
      <td>20:33:00</td>
      <td>Ewallet</td>
      <td>8.4</td>
      <td>0.33</td>
      <td>465.76</td>
    </tr>
    <tr>
      <th>4</th>
      <td>5</td>
      <td>WALM013</td>
      <td>Irving</td>
      <td>Sports and travel</td>
      <td>86.31</td>
      <td>7.0</td>
      <td>2019-02-08</td>
      <td>10:37:00</td>
      <td>Ewallet</td>
      <td>5.3</td>
      <td>0.48</td>
      <td>604.17</td>
    </tr>
  </tbody>
</table>
</div>




```python
engine_psql = create_engine("postgresql+psycopg2://postgres:password123@localhost:5432/project2")

try: 
    engine_psql
    print("connected")
except:
    print('no')
```

    connected



```python
df.to_sql(name='walmart', con=engine_psql, if_exists='append', index=False)
```




    969


