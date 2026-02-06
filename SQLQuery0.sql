
create database Sales ;

use Sales



select * from train

-- من جدول  Dim_Customers  باسم Dimanition عمل 
select distinct Customer_ID , Customer_Name , Segment , Country , City , State , Region into Dim_Customers
from train

select * from Dim_Customers


select Distinct  Product_ID , Product_Name , Category , Sub_Category  into Dim_Products
from train

with Dim_Customers_CTE as (
select * , ROW_NUMBER () over ( Partition by Customer_ID order by Customer_ID ) as RN
from Dim_Customers )

delete from Dim_Customers_CTE 
where RN > 1




with Dim_Products_CTE as (
select * , ROW_NUMBER () over ( Partition by Product_ID order by Product_ID ) as RN
from Dim_Products )

delete from Dim_Products_CTE 
where RN > 1



select * from train


select Distinct Order_ID , Ship_Mode into Dim_Orders
from train


with Dim_Orders_CTE as (
select * , ROW_NUMBER () over ( Partition by Order_ID order by Order_ID ) as RN
from Dim_Orders )

delete from Dim_Orders_CTE 
where RN > 1



alter table train 
drop column Ship_Mode , Customer_Name , Segment , Country , City , State , Region , Category , Sub_Category , Product_Name


select Distinct Order_Date into Dim_Date 
from train 

with Dim_Date_CTE as (
select * , ROW_NUMBER () over ( Partition by Order_Date order by Order_Date ) as RN
from Dim_Date )

delete from Dim_Date_CTE 
where RN > 1


alter table Dim_Date 
add  Order_Date1 date 

update Dim_Date
set Order_Date1 = Order_Date

select * from Dim_Date


alter table Dim_Date
alter column Order_Date varchar(50) 

update Dim_Date
set Order_Date = REPLACE(Order_Date , '-' , '')

exec sp_rename 'Dim_Date.Order_Date' , 'Order_Date_ID' , 'Column'
exec sp_rename 'Dim_Date.Order_Date1' , 'Order_Date' , 'Column'

ALTER TABLE Dim_Date
ADD 
    Year INT,
    Month INT,
    MonthName NVARCHAR(20);



    UPDATE Dim_Date
SET
    Year        = YEAR(Order_Date),
    Month = MONTH(Order_Date),
    MonthName   = DATENAME(MONTH, Order_Date);






select Distinct Ship_Date into Dim_Ship_Date
from train 


with Dim_Ship_Date_CTE as (
select * , ROW_NUMBER () over ( Partition by Ship_Date order by Ship_Date ) as RN
from Dim_Ship_Date )

delete from Dim_Ship_Date_CTE 
where RN > 1


alter table Dim_Ship_Date
add Ship_Date1 date

update Dim_Ship_Date
set Ship_Date1 = Ship_Date

select * from Dim_Ship_Date



alter table Dim_Ship_Date
alter column Ship_Date varchar(50) 

update Dim_Ship_Date
set Ship_Date = REPLACE(Ship_Date , '-' , '')



ALTER TABLE Dim_Ship_Date
ADD 
    Year INT,
    Month INT,
    MonthName NVARCHAR(20);



    UPDATE Dim_Ship_Date
SET
    Year        = YEAR(Ship_Date),
    Month = MONTH(Ship_Date),
    MonthName   = DATENAME(MONTH, Ship_Date);



    select * from train


alter table train
alter column Order_Date varchar(50) 

update train
set Order_Date = REPLACE(Order_Date , '-' , '')


exec sp_rename 'train.Order_Date_Id' , 'Order_Date_ID' , 'Column'



alter table train
alter column Ship_Date varchar(50) 

update train
set Ship_Date = REPLACE(Ship_Date , '-' , '')


exec sp_rename 'train.Ship_Date_Id' , 'Ship_Date_ID' , 'Column'

exec sp_rename 'Dim_Ship_Date.Ship_Date' , 'Ship_Date_ID' , 'Column'
exec sp_rename 'Dim_Ship_Date.Ship_Date1' , 'Ship_Date' , 'Column'




alter table Dim_Orders
add constraint Order_PK primary key (Order_ID)


alter table Dim_Customers
add constraint Customer_PK primary key (Customer_ID)


alter table Dim_Products
add constraint Product_PK primary key (Product_ID)


alter table Dim_Date
add constraint Date_PK primary key (Order_Date_ID)


alter table Dim_Date
alter column Order_Date_ID varchar(50) not null


alter table Dim_Ship_Date
alter column Ship_Date_ID varchar(50) not null

alter table Dim_Ship_Date
add constraint Ship_PK primary key (Ship_Date_ID)


exec sp_rename 'train' , 'Fact'


alter table Fact
add constraint FK_Order foreign key (Order_ID)
references Dim_Orders (Order_ID)



alter table Fact
add constraint FK_Customer foreign key (Customer_ID)
references Dim_Customers (Customer_ID)


alter table Fact
add constraint FK_Product foreign key (Product_ID)
references Dim_Products (Product_ID)


alter table Fact
add constraint FK_Date foreign key (Order_Date_ID)
references Dim_Date (Order_Date_ID)


alter table Fact
add constraint FK_Ship foreign key (Ship_Date_ID)
references Dim_Ship_Date (Ship_Date_ID)



     -- Analysis
-- Selas Of Citeis
with Citeis_Sales as (
select  C.City , Sum(F.Sales) as Sales
from Dim_Customers C join Fact F 
on C.Customer_ID = F.[Customer_ID]
group by City 
 )

select top 10  City , Sum(Sales) as Sales
from Citeis_Sales 
group by City 
order by  Sales desc


-- Sales Of Segments
with Segment_Sales as (
select C.Segment , sum(F.Sales) as Sales
from Dim_Customers C join Fact F 
on C.Customer_ID = F.Customer_ID 
group by Segment )

select *
from Segment_Sales 



-- Sales Of Regions
with Region_Sales as (
select C.Region , sum(F.Sales) as Sales
from Dim_Customers C join Fact F 
on C.Customer_ID = F.Customer_ID 
group by Region )

select *
from Region_Sales 




-- Sales Of Top 10 States
with States_Sales as (
select  C.State , Sum(F.Sales) as Sales
from Dim_Customers C join Fact F 
on C.Customer_ID = F.[Customer_ID]
group by State 
 )

select top 10 State ,  Sum(Sales) as Sales 
from States_Sales 
group by State
order by  Sales desc



-- Sales Of The Top 10 Customers + Number Of Orders Per Customer
with Customer_Sales as (
select  C.Customer_Name ,  O.Order_ID ,Sum(F.Sales) as Sales
from Dim_Customers C join Fact F 
on C.Customer_ID = F.[Customer_ID] 
join Dim_Orders O on O.Order_ID = F.Order_ID
group by Customer_Name , O.Order_ID  )

select top 10 Customer_Name , count(O.Order_ID) as Count_Orders  ,  Sum(Sales) as Sales
from Customer_Sales CS join Dim_Orders O 
on CS.Order_ID = O.Order_ID
group by CS.Customer_Name  
order by Sales desc 



--Sales Of Category
with Category_Sales as (
select P.Category , sum(F.Sales) as Sales 
from Dim_Products P join Fact F
on P.Product_ID = F.Product_ID 
group by P.Category )

select * 
from Category_Sales




-- Sales Of Top 10 Sub Category
with  Sales_Sub_Category as (
select  P.Sub_Category , sum(F.sales) as Sales
from Dim_Products P join Fact F
on P.Product_ID = F.Product_ID 
group by Sub_Category )

select top 10 Sub_Category , sum(sales) as Sales
from Sales_Sub_Category
group by  Sub_Category 
order by Sales desc


-- Top 10 Customers in Terms of Number Of Orders
with Customer_Sales as (
select  C.Customer_Name ,  O.Order_ID 
from Dim_Customers C join Fact F 
on C.Customer_ID = F.[Customer_ID] 
join Dim_Orders O on O.Order_ID = F.Order_ID
group by Customer_Name , O.Order_ID  )

select top 10 Customer_Name , count(O.Order_ID) as Count_Orders  
from Customer_Sales CS join Dim_Orders O 
on CS.Order_ID = O.Order_ID
group by CS.Customer_Name  
order by   Count_Orders desc 


-- Top 10 Customer
with Customer_Sales as (
select C.Customer_Name  , sum(F.Sales) as Total_Sales
from Dim_Customers C join Fact F 
on C.Customer_ID = F.Customer_ID 
group by C.Customer_Name ) ,

ranked_Customer as (
select * , 
rank () over (order by Total_Sales DESC ) as rankno
from Customer_Sales )

select * from ranked_Customer 
where rankno <= 10 ;



-- Sales Of Ship Mode + Count Order By Ship Mode
with Sales_Ship_Mode as (
select O.Ship_Mode , sum(F.Sales) as Sales , count(O.Order_ID)as Count_Orders
from Dim_Orders O join Fact F 
on F.Order_ID = O.Order_ID 
group by O.Ship_Mode )

select * 
from Sales_Ship_Mode
order by Sales DESC 



--Trend Month Analysis 
with Monthly_Sales as (
select D.Year , D.Month , D.MonthName , Sum(F.Sales) as Total_Sales
from Dim_Date D join Fact F 
on F.Order_Date_ID = D.Order_Date_ID 
group by D.Year , D.Month , D.MonthName )

select * 
from Monthly_Sales 
order by  Year , Month 



-- MOM Growth ( تحليل النمو الشهري )
with Monthly_Sales as (
select D.Year ,D.Month , D.MonthName , sum(F.Sales) as Total_Sales
from Dim_Date D join Fact F
on D.Order_Date_ID = F.Order_Date_ID 
group by D.Year ,D.Month , D.MonthName ),

Growth as (
select * , LAG(Total_Sales) over (order by year , month) as Prev_Month_Sales 
from Monthly_Sales )

select year , month , Total_Sales , Prev_Month_Sales , (Total_Sales - Prev_Month_Sales) as MOM_Change ,
round ( (Total_Sales - Prev_Month_Sales) * 100.0 / Prev_Month_Sales , 2) as MOM_Growth_Percent
from Growth



-- Product Performance Analysis ( افضب منتج في كل شهر )
with Monthly_Product_Sales as (
select D.Year , D.Month , D.MonthName  , P.Product_Name , sum(F.Sales) as Total_Sales
from Dim_Date D join Fact F 
on D.Order_Date_ID = F.Order_Date_ID 
join Dim_Products P on F.Product_ID = P.Product_ID
group by D.Year , D.Month , D.MonthName  , P.Product_Name ) ,

Ranked_Products as(
select * , 
ROW_NUMBER () over (partition by Year , Month order by Total_Sales DESC) as RN
from Monthly_Product_Sales )

select * 
from Ranked_Products
where RN = 1;






-- Product Performance Analysis ( افضب منتج في كل شهر )
with Monthly_Category_Sales as (
select D.Year , P.Category , sum(F.Sales) as Total_Sales
from Dim_Date D join Fact F 
on D.Order_Date_ID = F.Order_Date_ID 
join Dim_Products P on F.Product_ID = P.Product_ID
group by D.Year , P.Category) ,

Ranked_Category as(
select * , 
ROW_NUMBER () over (partition by Year  order by Total_Sales DESC) as RN
from Monthly_Category_Sales )

select * 
from Ranked_Category
where RN = 1;





with Monthly_Product_Sales as (
select D.Year ,P.Category, P.Product_Name , sum(F.Sales) as Total_Sales
from Dim_Date D join Fact F 
on D.Order_Date_ID = F.Order_Date_ID 
join Dim_Products P on F.Product_ID = P.Product_ID
group by D.Year ,P.Category ,P.Product_Name) ,

Ranked_Product as(
select * , 
ROW_NUMBER () over (partition by Year  order by Total_Sales DESC) as RN
from Monthly_Product_Sales )

select * 
from Ranked_Product
where RN = 1;



with Total as (
select Sum(F.Sales) as Total_Sales , AVG(F.Sales) as Average_Sales , Count(distinct C.[Customer_ID]) as Count_Customers ,
count(distinct O.Order_ID) as count_Orders , count(distinct P.Category) as Count_Category , count(distinct P.Product_Name) as Count_Products,
count(distinct P.Sub_Category) as Count_Sub_Category  , count(distinct C.City) as count_Cities , count(distinct C.Country )as Count_Countrys,
count (distinct C.Region) as Count_Regions , count(distinct C.Segment ) as  Count_Segments , count(distinct C.State ) as Count_States
from Fact F join Dim_Customers C
on F.Customer_ID = C.Customer_ID
join Dim_Orders O on O.Order_ID = F.Order_ID 
join Dim_Products  P on F.Product_ID = P.Product_ID )

select * 
from Total


