--DATA ANALYSIS FOR B2B RETAIL : CUSTOMER ANALYTIC REPORT


--Cek Tabel orders_1, orders_2, dan customer

select *
from orders_1;

select *
from orders_2;

select *
from customer;


--TOTAL SALES DAN REVENUE

select sum(a1.quantity) as total_sales, sum(a1.quantity * a1.priceeach) as total_revenue
from (
	select *
	from orders_1
	union
	select *
	from orders_2
	where statusOrder like '%Shipped%') as a1


--PERTUMBUHAN PENJUALAN

select sum(quantity) as total_sales,
	sum(quantity * priceeach) as revenue
	from orders_1  -- QUARTER PERTAMA	

select sum(quantity) as total_sales,
	sum(quantity * priceeach) as revenue
	from orders_2
	where statusOrder like '%Shipped%'  -- QUARTER KEDUA

select quarter, sum(t1.quantity) as total_sales,
	sum(t1.quantity * t1.priceeach) as revenue
	from (select 
		orderNumber, statusOrder, quantity, priceeach, '1' as quarter
		from orders_1
		union select orderNumber, statusOrder, quantity, priceeach, '2' as quarter
		from orders_2) as t1
	where statusOrder like '%Shipped%'
	group by quarter  -- QUARTER PERTAMA DAN KEDUA

select datename(month, a1.orderDate) as Month, sum(a1.quantity) as Total_Sales, sum(a1.quantity * a1.priceeach) as Total_Revenue
from
	(select *
	from orders_1
	union select *
	from orders_2
	where statusOrder like '%Shipped%') as a1
group by datename(month, a1.orderDate)  --MONTH


--PERTUMBUHAN CUSTOMERS PADA PERUSAHAAN DARI QUARTER PERTAMA HINGGA QUARTER KEDUA

select a1.quarter, count(distinct a1.customerID) as total_customers
from (
	select customerID, createDate,  datepart(quarter, createDate) as quarter
	from customer) as a1
group by quarter  --TOTAL CUSTOMERS DARI QUARTER PERTAMA HINGGA QUARTER KEDUA


select b1.quarter, count(distinct b1.customerID) as total_customers
from (
	select customerID, createDate, datepart(quarter, createDate) as quarter
	from customer) as b1
	where customerID in (
		select distinct(customerID)
		from orders_1
		union select distinct(customerID)
		from orders_2
		where statusOrder like '%Shipped%')
	group by quarter;    --TOTAL CUSTOMERS YANG MELAKUKAN TRANSAKSI


--TOTAL CUSTOMERS YANG BERTRANSAKSI DARI SETIAP NEGARA

select b1.country, a1.productCode, sum(a1.quantity * a1.priceeach)as Revenue
from
	(select *
	from orders_1
	union
	select *
	from orders_2
	where statusOrder like '%Shipped%') a1
	inner join customer as b1
	on a1.customerID = b1.customerID
group by b1.country, a1.productCode
order by country

select b1.country, count(distinct a1.quantity) as Total_Product
from
	(select *
	from orders_1
	union
	select *
	from orders_2
	where statusOrder like '%Shipped%') a1
	inner join customer as b1
	on a1.customerID = b1.customerID
group by country
order by Total_Product desc;


--PRODUK YANG PALING BANYAK DIBELI PADA QUARTER PERTAMA DAN QUARTER KEDUA

select *
from (
	select c1.categoryID, count(distinct c1.orderNumber) as total_order, sum(c1.quantity) as total_penjualan
	from (
		select productCode, orderNumber, quantity, statusOrder, left(productCode, 4) as categoryID
		FROM orders_1
		where statusOrder like '%Shipped%') c1
		group by categoryID) d1
	order by total_order desc;  --PRODUK YANG PALING BANYAK DIBELI PADA QUARTER 1

select *
from (
	select e1.categoryID, count(distinct e1.orderNumber) as total_order, sum(e1.quantity) as total_penjualan
	from (
		select productCode, orderNumber, quantity, statusOrder, left(productCode, 4) as categoryID
		FROM orders_2
		where statusOrder like '%Shipped%') e1
		group by categoryID) f1
	order by total_order desc;  --PRODUK YANG PALING BANYAK DIBELI PADA QUARTER 2


select b1.productID, count(distinct b1.orderNumber) as total_order, sum(b1.quantity) as total_sales
	from
	(select a1.productCode, a1.orderNumber, a1.quantity, a1.statusOrder, left(a1.productCode, 4) as productID
	from
		(select *
		from orders_1
		union select *
		from orders_2
		where statusOrder like '%Shipped%') as a1) as b1
		group by b1.productID  --TOTAL TOP PRODUK



--MENGHITUNG RETENTION RATE

select '1' as quarter, (count(distinct customerID)*100)/25 as retention_rate
from orders_1
where customerID in (
	select distinct(customerID)
	from orders_2)



