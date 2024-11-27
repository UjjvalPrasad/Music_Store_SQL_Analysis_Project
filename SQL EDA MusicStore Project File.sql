-- 1. Who is the senior most employee based on job title?
select * from employee
order by levels desc
limit 1;

-- 2. Which countries have the most Invoices?
select billing_country, count(total) Invoice_Count from invoice
group by billing_country
order by Invoice_Count desc;

-- 3. What are top 3 values of total invoice?
select total from invoice
order by total desc
limit 3;

-- 4. Which city has the best customers? 
-- We would like to throw a promotional Music Festival in the city we made the most money.
-- Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals.
select billing_city, sum(total)  from invoice
group by billing_city
order by sum(total) desc
limit 1;

-- 5. Who is the best customer?
-- The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money.
select first_name, last_name, sum(total) most_spent from customer c
join invoice i on c.customer_id = i.customer_id
group by c.customer_id
order by most_spent desc
limit 1;

-- 6. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A.
select distinct c.email Email, c.first_name FirstName, c.last_name LastName, g.name GenreName 
from customer c
join invoice i on i.customer_id = c.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join genre g on g.genre_id = t.genre_id
where g.name like 'Rock'
order by email asc;

-- 7. Let's invite the artists who have written the most rock music in our dataset.
-- Write a query that returns the Artist name and total track count of the top 10 rock bands.
select a.name, count(t.track_id) total_track_count from artist a
join album ab on ab.artist_id = a.artist_id
join track t on t.album_id = ab.album_id
join genre g on g.genre_id = t.genre_id
where g.name like 'Rock'
group by a.name
order by total_track_count desc
limit 10;

-- 8. Return all the track names that have a song length longer than the average song length.
-- Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.
select t.name, t.milliseconds track_length from track t
where t.milliseconds > (select avg(milliseconds) from track)
order by track_length desc;

-- 9. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent
WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	limit 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

-- 10. We want to find out the most popular music Genre for each country.
-- We determine the most popular genre as the genre with the highest amount of purchases.
-- Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres
WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1

-- 11. Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount.
with top_customer as
(
	select c.first_name, c.last_name, c.country, sum(i.total), 
	rank() over(partition by country order by sum(i.total) desc) as rnk
	from customer c
	join invoice i on c.customer_id = i.customer_id
	group by 1,2,3
	order by c.country
)
select * from top_customer where rnk <= 1;