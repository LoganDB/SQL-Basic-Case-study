                            /*SQL Case Study Basic*/
					--DATA PREPARATION AND UNDERSTANDING--
--Q1:

select count(*) as Row_count from dbo.Customer
union all 
select count(*) from dbo.Transactions
union all
select count(*) from dbo.prod_cat_info;

--Q2:
select count(transaction_id) as cnt_trnsc_return from dbo.Transactions where try_convert(float,total_amt)<0;

--Q3:
select convert(date,DOB,105) as DOB from dbo.Customer;
select convert(date,tran_date,105) as tran_date from dbo.Transactions;

--Q4:
select
DATEDIFF(YEAR,min(convert(date,tran_date,105)),max(convert(date,tran_date,105))) as Year_diff,
DATEDIFF(MONTH,min(convert(date,tran_date,105)),max(convert(date,tran_date,105)))as Month_diff,
DATEDIFF(DAY,min(convert(date,'22-02-2011',105)),max(convert(date,'28-02-2014',105)))as Day_diff
from dbo.Transactions;


--Q5:
select prod_cat from dbo.prod_cat_info where prod_subcat='DIY'; 

                               --DATA ANALYSIS--
--Q1:
select top 1 Store_type
from dbo.Transactions
group by Store_type 
order by count(*) desc;

--Q2:
select gender, count(*) as Gender_count
from dbo.Customer
where gender <>''
group by Gender;

--Q3:
select top 1 city_code, count(customer_Id) as Max_customer
from dbo.Customer
group by city_code;

--Q4:
select prod_cat, count(prod_subcat) as count_sub
from dbo.prod_cat_info
where prod_cat='Books'
group by prod_cat;

--Q5:
select max(Qty) as Max_Quantity
from dbo.Transactions;

--Q6:
select sum(TRY_CONVERT(float,total_amt)) as Net_tot_revenue
from dbo.Transactions as t1
full outer join dbo.prod_cat_info as t2 on t1.prod_cat_code=t2.prod_cat_code and t1.prod_subcat_code=t2.prod_sub_cat_code
where prod_cat in ('Books','Electronics')

--Q7:
select count(*) from(select cust_id as Cnt_customer  
from dbo.Transactions
where try_convert(float,total_amt)>0
group by cust_id
having count(transaction_id)>10
)
   -- There are six Customer which have transaction more than 10 and exclusive of return--

--Q8:
select Store_type,sum(TRY_CONVERT(float,total_amt)) as Combined_revenue
from dbo.Transactions as t1
full outer join dbo.prod_cat_info as t2 on t1.prod_cat_code=t2.prod_cat_code and t1.prod_subcat_code=t2.prod_sub_cat_code
where Store_type in ('Flagship store') and prod_cat in ('Electronics','Clothing') 
group by Store_type;

--Q9:
select prod_subcat,sum(try_convert(float,total_amt)) as Total_revenue
from dbo.Customer as t1
full outer join dbo.Transactions as t2 on t1.customer_Id=t2.cust_id
full outer join dbo.prod_cat_info as t3 on t2.prod_cat_code=t3.prod_cat_code and t2.prod_subcat_code=t3.prod_sub_cat_code
where Gender='M' and prod_cat='Electronics'
group by prod_subcat;

--Q10:
select top 5 prod_subcat,sum(case WHEN TRY_CONVERT(float,total_amt) > 0 THEN 1 ELSE 0 END) AS 'Sales',
sum(case WHEN TRY_CONVERT(float,total_amt) > 0 THEN 1.0 ELSE 0 END) /Count(*) *100 AS 'Sales_percent',
sum(case WHEN TRY_CONVERT(float,total_amt) < 0 THEN 1 ELSE 0 END) AS 'Returns',
sum(case WHEN TRY_CONVERT(float,total_amt) < 0 THEN 1.0 ELSE 0 END) /Count(*) *100 AS 'Return_percent'
from dbo.Transactions as t1
full outer join dbo.prod_cat_info as t2 on t1.prod_subcat_code=t2.prod_sub_cat_code and t1.prod_cat_code=t2.prod_cat_code
group by prod_subcat 
order by sales desc;
 
--Q11: 
select DOB,DATEDIFF(year,try_convert(date,DOB,105), getdate()) as Age_btw_25_to_35,sum(try_convert(float,total_amt)) as Total_revenue,
DATEAdd(day,-30,max(try_convert(date,tran_date,105))) as last_transac
from dbo.Customer as t1
full outer join dbo.Transactions as t2 on t1.customer_Id=t2.cust_id
where (DATEDIFF(year,try_convert(date,DOB,105), getdate()) between 25 and 35)
group by DOB,tran_date
having try_convert(date,tran_date,105)>=DATEAdd(day,-30,max(try_convert(date,tran_date,105)))
order by last_transac;

--Q12:
select top 1 prod_cat,sum(try_convert(float,total_amt)) as Max_return,DATEAdd(month,-3,max(try_convert(date,tran_date,105))) as Last_3_months
from dbo.prod_cat_info as t1 
full outer join dbo.Transactions as t2 on t1.prod_cat_code=t2.prod_cat_code and t1.prod_sub_cat_code=t2.prod_subcat_code
where TRY_CONVERT(float,total_amt)<0 
group by prod_cat,tran_date
having TRY_CONVERT(date,tran_date,105)>=DATEAdd(month,-3,max(try_convert(date,tran_date,105)))
order by Max_return; 

--Q13:
select top 1 Store_type,sum(try_convert(float,total_amt)) as sales_amount,Qty as sell_quantity
from dbo.Transactions
where try_convert(float,total_amt)>0
group by Store_type,Qty
having qty>0
order by Qty desc,sales_amount desc;

--Q14:
select prod_cat,avg(TRY_CONVERT(float,total_amt)) as average_revenue
from dbo.prod_cat_info as t1
full outer join dbo.Transactions as t2 on t1.prod_cat_code=t2.prod_cat_code and t1.prod_sub_cat_code=t2.prod_subcat_code
group by prod_cat
having avg(TRY_CONVERT(float,total_amt)) >(select avg(TRY_CONVERT(float,total_amt)) as Overall_average_revenue from dbo.Transactions);

--Q15:
select prod_subcat,sum(try_convert(float,total_amt)) as Total_revenue,avg(TRY_CONVERT(float,total_amt)) as average_revenue 
from dbo.prod_cat_info as t1
full outer join dbo.Transactions as t2 on t1.prod_cat_code=t2.prod_cat_code and t1.prod_sub_cat_code=t2.prod_subcat_code
where exists
(
select top 5 prod_cat,sum(try_convert(float,Qty)) as Net_Quantity from dbo.prod_cat_info as t3
full outer join dbo.Transactions as t4 on t3.prod_cat_code=t4.prod_cat_code and t3.prod_sub_cat_code=t4.prod_subcat_code
group by prod_cat
order by  Net_Quantity desc
)
group by prod_subcat;  


 

