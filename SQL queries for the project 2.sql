CREATE DATABASE project2_music_store_analysis;
use project2_music_store_analysis;

-- 1. Who is the seniormost employee based on job title
SELECT employee_id, CONCAT(first_name,' ', last_name) AS full_name, title 
FROM employee
ORDER BY levels DESC
LIMIT 1;

-- 2. Which countries have the most invoices
SELECT COUNT(invoice_id) as Invoice_Count, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY Invoice_Count DESC;

-- 3. What are top 3 values of total invoice
SELECT invoice_id, customer_id, billing_country, total
FROM invoice
ORDER BY total DESC
LIMIT 3;

-- 4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
-- Write a query that returns one city that has the highest sum of invoice totals.  Return both the city name & sum of all invoice totals
SELECT billing_city, SUM(total) AS invoice_totals
FROM invoice
GROUP BY billing_city
ORDER BY invoice_totals DESC
LIMIT 1;

-- 5. Who is the best customer? The customer who has spent the most money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money.
SELECT c.customer_id, CONCAT(c.first_name,' ', c.last_name) AS customer_details, SUM(total) AS spent_money
FROM customer as c
JOIN invoice i
ON c.customer_id = i.customer_id
GROUP BY c.customer_id, customer_details
ORDER BY spent_money DESC
LIMIT 1;

-- 6. Write query to return the email, first name, last name, & Genre of all Rock Music listeners.  
-- Return your list ordered alphabetically by email starting with A
SELECT DISTINCT c.email, c.first_name, c.last_name, g.name FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name LIKE 'Rock'
ORDER BY c.email;

-- 7. Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands.
SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;

-- 8. Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.
SELECT name AS track_name, milliseconds AS song_length FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
order by milliseconds desc;

-- 9. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent
WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY artist_id
	ORDER BY total_sales DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY amount_spent DESC;

