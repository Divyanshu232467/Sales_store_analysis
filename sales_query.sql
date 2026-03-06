--STEP 1 : CREATING A DATABASE/Table
create database Sales_dataset

use Sales_dataset

create table sales_store(
transaction_id varchar(15),customer_id	varchar(15),customer_name	varchar(30),customer_age int,
gender	varchar(15),product_id	varchar(15),product_name	varchar(30),
product_category varchar(15),quantiy int,prce float,payment_mode varchar(15),purchase_date	date,
time_of_purchase time, status varchar(15));

-- Importing Dataset

SET DATEFORMAT dmy
BULK INSERT sales_store
FROM 'C:\Users\Dell\Desktop\sql_projects\Sales_data_analysis\Sales_dataset.csv'
	with(
		FIRSTROW=2,
		FIELDTERMINATOR=',',
		ROWTERMINATOR='\n'
	);

select * from sales_store

--  Creating copy of data

select * from sales_store
SELECT * INTO SALES FROM sales_store

-- Step 2: DATA CLEANING

--STEP 1 : TO CHECK FOR DUPLICATE

SELECT TRANSACTION_ID ,COUNT(*) COUNT FROM SALES
GROUP BY TRANSACTION_ID 
HAVING COUNT(TRANSACTION_ID)>1;

TXN240646
TXN342128
TXN855235
TXN981773

WITH CTE AS(
SELECT * ,
ROW_NUMBER() OVER (PARTITION BY TRANSACTION_ID ORDER BY TRANSACTION_ID) AS ROW_NUM
FROM SALES
)
SELECT * FROM CTE 
WHERE TRANSACTION_ID IN('TXN240646','TXN342128','TXN855235','TXN981773')

-- Step 2: DELETEING A DUPLICATE ROWS


WITH CTE AS(
SELECT * ,
ROW_NUMBER() OVER (PARTITION BY TRANSACTION_ID ORDER BY TRANSACTION_ID) AS ROW_NUM
FROM SALES
)
DELETE FROM CTE 
WHERE ROW_NUM=2;

--CORRECTION OF HEADERS



EXEC sp_rename 'Sales.quantiy','quantity','column'
EXEC sp_rename 'Sales.prce','price','column'

-- STEP 3 : To Check Datatype

SELECT COLUMN_NAME,DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='sales'

-- STEP 4: To Check Null Values

-- Treating null values

select * from sales
where transaction_id is null
or customer_id is null
or customer_name is null
or customer_age is null
or gender is null
or product_id is null
or product_name is null
or product_category is null
or quantity is null
or price is null
or payment_mode is null
or purchase_date is null
or time_of_purchase is null
or status is null

-----Deleteting outliers
delete from sales 
where transaction_id is NULL

--replacing null values 

select * from sales
where customer_name in ('Ehsaan Ram','Damini Raju')

CUST9494- Ehsaan Ram
CUST1401- Damini Raju

-- Updating Values
update sales 
set customer_id='CUST9494'
where customer_name='Ehsaan Ram'

update sales 
set customer_id='CUST1401'
where customer_name='Damini Raju'

-- filling null in customers_name

select customer_name from sales
where customer_id = 'CUST1003'

update sales
set customer_name='Mahika Saini',customer_age=35,gender='Male'
where transaction_id ='TXN432798'


-- Step 5: Data Cleaning
select distinct gender 
from sales

update sales
set gender='Male'
where gender='M'

update sales
set gender='Female'
where gender='F'

select distinct payment_mode 
from sales

update sales
set payment_mode='Credit Card'
where payment_mode='CC'


-- Step 3 : DATA ANALYSIS

-- 1. What are the top 5 most selling products by quantity?

select top 5 product_name ,sum(quantity) as total_qty 
from sales 
where status='delivered'
group by product_name
order by total_qty desc

-- Business Problem :- We don't know which products are most in demand
-- Business Impact :- Helps in prioritize stocks and boost sales through targeted promotions

-- 2. Which product are most frequently cancelled?

select top 5 product_name,count(status) as total_cancelled
from sales 
where status='Cancelled'
group by product_name
order by total_cancelled desc

-- Business Problem :- Frequently cancelled affects revenue and customers trust
-- Business Impact :- Identify poor performing products to improve quality or remove from catalog

-- 3. What time of the day has the highest number of purchases?

select
	case
		when DATEPART(HOUR,time_of_purchase) between 0 and 5 then 'Night'
		when DATEPART(hour,time_of_purchase) between 6 and 11 then 'Morning'
		when DATEPART(hour,time_of_purchase) between 12 and 17 then 'Afternoon'
		when DATEPART(hour,time_of_purchase) between 18 and 23 then 'Evening'
	End as time_of_day,
	count(*) as total_orders
from SALES
group by case
		when DATEPART(HOUR,time_of_purchase) between 0 and 5 then 'Night'
		when DATEPART(hour,time_of_purchase) between 6 and 11 then 'Morning'
		when DATEPART(hour,time_of_purchase) between 12 and 17 then 'Afternoon'
		when DATEPART(hour,time_of_purchase) between 18 and 23 then 'Evening'
	End
order by total_orders desc


-- Business Problem :- Find peak sales time
-- Business Impact :- Optimize Staffing, Promotions and Server Loads

-- 4. Who are the top 5 highest spending customers


select top 5 customer_name,
	format(sum(price*quantity),'C0','en-IN') as total_money_spend
from sales
group by customer_name
order by sum(price*quantity) desc

-- Business Problem :- Identify VIP Customers
-- Business Impact :- Personaized offers, loyalty rewards and retention

-- 5. Which product category generate the highest revenue?

select product_category ,
		format(sum(price*quantity),'C0','en-IN') as total_revenue
from sales
group by product_category
order by sum(price*quantity) desc

-- Business Problem :- Identify Top performing product category
-- Business Impact :- REfine product strategy,supplychain and promotions ,allowing the business to invest more
					-- high demand categories

-- 6. What is the return/cancellation rate per product category?

-- Cancelled
select product_category,
	format(count(case
			when status='cancelled' then 1
		end)*100.0/count(*),'N3')+'%' as cancelled_percent
from sales
group by product_category
order by cancelled_percent desc

-- Return
select product_category,
	format(count(case
			when status='returned' then 1
		end)*100.0/count(*),'N3')+'%' as returned_percent
from sales
group by product_category
order by returned_percent desc


--Business Problem :- Monitor dissatisfaction trends per category
-- Business Impact :- Reduce return, improve product descriptions/exceptions.
					-- Helps identify and fix product or logistics  issues

-- 7. What is the most preferred payment mode

select payment_mode,count(payment_mode) as total_count
from sales 
group by payment_mode 
order by total_count desc

--Business Problem :- Know which payment option customer prefered most
-- Business Impact :- Streamline payment processing,prioritize popular modes.

-- 8. Hoe does a age group affect purchasing behaviour

select 
	case 
		when customer_age between  18 and 25 then '18-25'
		when customer_age between  26 and 35 then '26-35'
		when customer_age between  36 and 50 then '36-50'
		else '51+'
		end as customer_age,
	format(sum(price*quantity),'C0','en-IN') as total_purchase 
from sales
group by case 
		when customer_age between  18 and 25 then '18-25'
		when customer_age between  26 and 35 then '26-35'
		when customer_age between  36 and 50 then '36-50'
		else '51+'
		end
order by sum(price*quantity) desc


--Business Problem :- Understand customer demographics
-- Business Impact :- Targeted marketing and product recommendations by age group.

-- 9. What is the montly sales trend
------ Method 1
select 
	format(purchase_date,'yyyy-MM') as month_year,
	format(sum(price*quantity),'C0','en-IN') as total_sales,
	sum(quantity) as total_quantity
from sales
group by format(purchase_date,'yyyy-MM')-

------ Method 2
select 
	year(purchase_date) as years,
	month(purchase_date) as months,
	format(sum(price*quantity),'C0','en-IN') as total_sales,
	sum(quantity) as total_quantity
from sales
group by year(purchase_date),month(purchase_date)
order by months


--Business Problem :- Sales fluctuation go unnoticed
-- Business Impact :- Plan inventory and marketing according to seasonal trends.

-- 10. Are certain genders buying more specific product categories?

-- Method 1
select gender ,product_category,count(product_category) as total_purchase
from sales
group by gender,product_category
order by gender 

-- Method 2
select *
from(select  gender,product_category
		from sales) as source_table
	pivot(
		count(gender)
		for gender in ([Male],[Female])
		) as pivot_table
order by product_category


--Business Problem :- Gender based product preferences
-- Business Impact :- Personalized ads,gender-focused campaigns