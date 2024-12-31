-- Subj.1 
with cte as (select g.name, a.title, count(i.invoice_id) as cnt from track t
join album a on t.album_id=a.album_id
join invoice_line il on t.track_id=il.track_id
join invoice i on il.invoice_id=i.invoice_id
join genre g on t.genre_id=g.genre_id
where billing_country="USA"
group by g.name, a.title
order by g.name, cnt)

select *,rank() over(partition by name order by cnt desc) as rnk from cte
order by cnt desc

-- Subj. 2
with cte as (select billing_country, g.name, count(i.invoice_id) as total_sold_track from track t
join invoice_line il on t.track_id=il.track_id
join invoice i on il.invoice_id=i.invoice_id
join Genre g on t.genre_id=g.genre_id
where billing_country <> 'USA'
group by billing_country, g.name),

cte1 as (select *, rank() over(partition by billing_country order by total_sold_track desc) as rnk from cte)

select*from cte1 where rnk=1

-- Subj. 3
with cte as (select customer_id, datediff(max(invoice_date),min(invoice_date)) as days_active, count(invoice_id) as cnt, sum(total) as total_spent from invoice
group by customer_id
order by cnt, total_spent)

select cte.customer_id, country, days_active, cnt, total_spent from cte
join customer c on cte.customer_id=c.customer_Id
order by cnt desc

-- Subj. 4
with cte as (select customer_id, g.name, count(i.invoice_id) as G_pur_cnt, rank() over(partition by customer_id order by count(i.invoice_id) desc) as rnk from track t
join invoice_line il on t.track_id=il.track_id
join invoice i on il.invoice_id=i.invoice_id
join Genre g on t.Genre_id=g.Genre_id
group by customer_id, g.genre_id
order by customer_id, G_pur_cnt desc)

select*from cte where rnk<3

with cte as (select customer_id, ar.name, count(i.invoice_id) as G_pur_cnt, rank() over(partition by customer_id order by count(i.invoice_id) desc) as rnk from track t
join invoice_line il on t.track_id=il.track_id
join invoice i on il.invoice_id=i.invoice_id
join album al on t.album_id=al.album_id
join artist ar on al.artist_id=ar.artist_id
group by customer_id, ar.name
order by customer_id, G_pur_cnt desc)

select*from cte where rnk<3
    
-- Subj.5 
with cte as (select year(invoice_date) as yr, billing_country, count(distinct(customer_id)) as cnt from invoice
group by yr,billing_country),
cte1 as (select*, lag(cnt) over(partition by billing_country order by yr desc) as ld from cte
order by yr)
select *from cte1
order by cnt desc, billing_country, yr

-- Subj.6
with cte as (select year(invoice_date) as yr,billing_country, count(distinct(customer_id)) as cnt from invoice
group by yr, billing_country),
cte1 as (select*, lag(cnt) over(order by yr desc) as ld from cte
order by yr)
select *, (cnt-ld)*100/cnt as percentage_churn from cte1
order by percentage_churn desc

-- Subj.7
with cte as (select year(invoice_date) as yr,billing_country, count(distinct(customer_id)) as cnt from invoice
group by yr, billing_country),
cte1 as (select*, lag(cnt) over(order by yr desc) as ld from cte
order by yr)
select *, (cnt-ld)*100/cnt as percentage_churn from cte1
order by percentage_churn desc

-- Subj.10
alter table Album
add Release_year int
