-- Obj. 1
SELECT *from Track
WHERE track_id is null or genre_id is null or name is null or album_id is null

SELECT Track_id, count(Track_id) 
FROM Track
GROUP BY Track_id
HAVING COUNT(Track_id) > 1
WHERE track_id is null or genre_id is null or name is null or album_id is null

-- Obj. 2

select track_id, sum(quantity) as totalsold from invoice_line il
join invoice i on il.invoice_id=i.invoice_id
where billing_country="USA"
group by track_id

select ar.name, sum(quantity) as totalsold from invoice_line il
join track t on il.track_id=t.track_id
join album al on t.album_id=al.album_id
join artist ar on al.artist_id=ar.artist_id
join invoice i on il.invoice_id=i.invoice_id
where billing_country="USA"
group by name	
order by totalsold desc

with cte as (select ar.name as ar_name, g.name as genre_name, sum(quantity) as totalsold, rank() over(partition by ar.name order by sum(quantity)) as rnk from invoice_line il
join track t on il.track_id=t.track_id
join album al on t.album_id=al.album_id
join artist ar on al.artist_id=ar.artist_id
join genre g on t.genre_id=g.genre_id
group by ar.name, g.name)
select ar_name, genre_name from cte where rnk=1
order by totalsold desc

-- Obj.3
with cte as (select country, count(customer_id) as cnt from customer
group by country)
select*, cnt*100/(select sum(cnt) from cte) as percentage_distribution from cte
order by cnt desc

with cte as (select billing_country, count(customer_id) as cnt from invoice
group by billing_country)
select*, cnt*100/(select sum(cnt) from cte) as percentage_distribution from cte
order by cnt desc

-- Obj.4
select billing_country as country, billing_state as state, billing_city as city, count(invoice_id) as total_invoices, sum(total) as revenue from invoice
group by billing_country, billing_state, billing_city

select billing_country as country, count(invoice_id) as total_invoices, sum(total) as revenue from invoice
group by billing_country

select billing_state as state, count(invoice_id) as total_invoices, sum(total) as revenue from invoice
group by billing_state

select billing_city as city, count(invoice_id) as total_invoices, sum(total) as revenue from invoice
group by billing_city

-- Obj.5
with cte as (select customer_id, billing_country, sum(total) as revenue from invoice
group by customer_id, billing_country),
cte1 as (SELECT *, rank() over(partition by billing_country order by revenue desc) as rnk  FROM cte)
select c.customer_id,concat(first_name," ",last_name) as customer_name, billing_country as country, revenue from cte1
join customer c on cte1.customer_id=c.customer_id where rnk<=5

-- Obj.6
with cte as (select customer_id, track_id, count(track_id) as cnt from invoice_line il
join invoice i on il.invoice_id=i.invoice_id
group by customer_id, track_id),

cte1 as (select*, rank() over(partition by customer_id, track_id order by cnt desc) as rnk from cte)
select customer_id, track_id from cte1 where rnk=1

-- Obj.7
select billing_country, avg(total) as revenue from invoice
group by billing_country
order by revenue desc

select g.name, avg(total) as totals from track t
join invoice_line il on t.track_id=il.track_id
join invoice i on il.invoice_id=i.invoice_id
join genre g on t.genre_id=g.genre_id
group by g.name
order by totals desc

-- Obj.8
with cte as (select year(invoice_date) as yr, count(distinct(customer_id)) as cnt from invoice
group by yr),
cte1 as (select*, lag(cnt) over(order by yr desc) as ld from cte
order by yr)
select *, (cnt-ld)*100/cnt as percentage_churn from cte1

-- Obj.9
with cte as (select g.name, sum(total) as totals from track t
join invoice_line il on t.track_id=il.track_id
join invoice i on il.invoice_id=i.invoice_id
join genre g on t.genre_id=g.genre_id
where billing_country="USA"
group by g.name)
select *, totals*100/(select sum(totals) from cte) as percentage from cte
order by totals desc

select ar.name, count(i.invoice_id) as cnt from track t
join album a on t.album_id=a.album_id
join artist ar on a.artist_id=ar.artist_id
join invoice_line il on t.track_id=il.track_id
join invoice i on il.invoice_id=i.invoice_id
group by ar.name
order by cnt desc

-- Obj. 10
select customer_id, count(distinct(genre_id)) as cnt from track t
join invoice_line il on t.track_id=il.track_id
join invoice i on il.invoice_id=i.invoice_id
group by customer_id
having cnt>=3
order by cnt desc

 -- Obj. 11
 with cte as (select genre_id, sum(quantity) as total_sold_track from track t
join invoice_line il on t.track_id=il.track_id
join invoice i on il.invoice_id=i.invoice_id
group by genre_id)

select*, rank() over(order by total_sold_track desc) as `rank` from cte

 -- Obj. 12
 *Below query gives customer_id who didn’t purchased in last three months  
with cte as (select distinct(customer_id) from invoice
where invoice_date>((select max(invoice_date) from invoice)-interval 3 month))
select distinct(customer_id) from invoice
where customer_id not in(select customer_id from cte)

