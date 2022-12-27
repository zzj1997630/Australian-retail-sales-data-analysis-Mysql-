CREATE DATABASE Research;
use Research;
CREATE TABLE Customer(
customer_id INT PRIMARY KEY,
customer_name VARCHAR(40),
age INT,
gender varchar(20),
home_address VARCHAR(200),
zip_code INT,
city VARCHAR(40),
state VARCHAR(40),
country VARCHAR(40)
);

CREATE TABLE Orders(
order_id INT primary KEY,
Customer_id INT,
payment INT,
order_date DATE,
delivery_date date,
foreign key(Customer_id) References research.customer(customer_id) on delete set null
);
Create table  Products(
product_ID INT PRIMARY KEY,
product_type varchar(40),
product_name VARCHAR(40),
size VARCHAR(10),
colour VARCHAR(20),
price INT,
quantity INT,
description varchar(300)
);
CREATE TABLE Sales(
sales_id INT primary key,
order_id int,
product_id int,
price_per_unit int,
quantity int,
total_price int,
foreign key(order_id) references research.orders(order_id) on delete set null,
foreign key(product_id) references research.products(product_id) on delete set null
);
#make 4 tables for the 4 csv datasets
#DROP TABLE Customer;
#DROP TABLE Orders;
#DROP TABLE Products;
#DROP TABLE Sales;

select*from products
limit 5; 
select*from sales
limit 5;
select*from orders
limit 5;
select*from customer
limit 5;

#Which products were sold the most in the last month?
select sales.product_ID, products.product_name,sales.quantity,sales.total_price,products.description,orders.order_date
from sales
join products
on sales.product_ID=products.product_ID
join orders
on orders.order_id=sales.order_id
where orders.order_date>'2021-10-20'
order by sales.total_price DESC
limit 10;




#How did the revenue change in the last 4 quarters?
select sum(sales.total_price) as revenue,order_quarters
from (select orders.order_id,order_date,
CASE  
	when order_date between '2021-01-01' and '2021-03-31' then 'First quarter'
	when order_date between '2021-04-01' and '2021-06-30' then 'Second quarter'
	when order_date between '2021-07-01' and '2021-09-30' then 'third quarter'
	when order_date between '2021-10-01' and '2021-12-31' then 'Fourth quarter'
end as 'order_quarters'
from orders
) as ORDERS
join sales
on sales.order_id=ORDERS.order_id
group by order_quarters
order by  revenue DESC;

#how much money customer that can save?
select sum((sales.price_per_unit-products.price)*sales.quantity )as discount,order_quarters
from (select order_id,order_date,
CASE  
	when order_date between '2021-01-01' and '2021-03-31' then 'First quarter'
	when order_date between '2021-04-01' and '2021-06-30' then 'Second quarter'
	when order_date between '2021-07-01' and '2021-09-30' then 'third quarter'
	when order_date between '2021-10-01' and '2021-12-31' then 'Fourth quarter'
end as 'order_quarters'
from orders
) AS ORDERS
join sales
on sales.order_id=ORDERS.order_id
join products
on sales.product_ID=products.product_ID
group by ORDERS.order_quarters
order by discount desc;





select *,
CASE  
	when order_date between '2021-01-01' and '2021-03-31' then 'First quarter'
	when order_date between '2021-04-01' and '2021-06-30' then 'Second quarter'
	when order_date between '2021-07-01' and '2021-09-30' then 'third quarter'
	when order_date between '2021-10-01' and '2021-12-31' then 'Fourth quarter'
end as order_quarters
from orders;




#the distribution of our customer(state)
select count(customer_id) as customer_number,concat(round(count(customer_id)/1000*100,2),'%') as ratio,state
from customer
group by state
order by customer_number desc;

#the distribution of our customer(gender)
select count(customer_id) as customer_number,concat(round(count(customer_id)/1000*100,2),'%') as ratio,gender
from customer
group by gender
order by customer_number desc;

#the distribution of our customer(age)
select count(customer_id) as customer_number,concat(round(count(customer_id)/1000*100,2),'%') as ratio,age_range
from (select customer_id,age,
case when age between 0 and 20 then 'teenager and young people'
when age between 21 and 30 then '21-30'
when age between 31 and 40 then'31-40'
when age between 41 and 50 then'41-50'
when age between 51 and 60 then'51-60'
when age between 61 and 70 then'61-70'
when age between 71 and 130 then 'very old people'
end as age_range
from customer
) as Age
group by age_range
order by ratio desc;


#Check how fast that our customers receive the products
select avg(delivery_date-order_date) as average_time_receive,min(delivery_date-order_date) as fastest_receive,
max(delivery_date-order_date) as slowest_receive
from orders;
select order_id,customer.customer_id,customer_name,age,gender,state,delivery_date-order_date as delivery_time
from customer
join orders
on customer.customer_id=orders.Customer_id
order by delivery_time desc
limit 10;

#vip client
select customer.customer_id,customer.customer_name,age,gender,state,sum(orders.payment) as all_payment,count(order_id) as number_orders,avg(delivery_date-order_date) as average_delivery_time
from customer
join orders
on customer.customer_id=orders.Customer_id,
group by customer_name
order by all_payment desc
limit 10;


#what is our important product
select products.product_name,products.colour,sum(sales.total_price) as full_payment,sum(sales.quantity) as quantity,avg(delivery_date-order_date) as average_delivery_time
from products
join sales
on sales.product_id=products.product_ID
join orders
on sales.order_id=orders.order_id
group by product_name,colour
order by full_payment desc
limit 10;

