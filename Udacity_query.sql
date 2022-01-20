/* Query 1 for first visual- From Set 1 Question 1 */
/*Query that lists each movie, the film category it is classified in, and the number of times it has been rented out. */

WITH T1 AS (SELECT sub.film_title, sub.category_name, COUNT(*) AS rental_count
FROM
   (SELECT f.title film_title, c.name category_name
	FROM category c
	JOIN film_category fc
	ON c.category_id = fc.category_id
	JOIN film f
	ON f.film_id = fc.film_id
	JOIN inventory i
	ON i.film_id = f.film_id
	JOIN rental r
	ON r.inventory_id = i.inventory_id
	WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music'))sub
	GROUP BY sub.category_name, sub.film_title
	ORDER BY rental_count DESC
	Limit 10);
 
 SELECT * 
 FROM T1
 ORDER BY film_title 

 /* Query 2 for Second visual- From Set 1 Question 2 */
/*Query with movie titles that divide them into 4 levels based on their quartiles of the rental duration for movies across all categories*/

WITH CTE_t1 AS (SELECT f.title, c.name, f.rental_duration
FROM category c
JOIN film_category fc
ON c.category_id = fc.category_id
JOIN film f
ON f.film_id = fc.film_id
WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
AND title LIKE 'E%');

SELECT title, name, MAX(rental_duration) max_rental
FROM CTE_t1
GROUP BY 1,2
ORDER BY max_rental DESC

/* Query 3 for Third visual- From Set 1 Question 3 */
/*Query with the family-friendly film category,each of the quartiles,and the corresponding count of movies within each combination of 
film category for each corresponding rental duration category*/

WITH CTE_customers AS (SELECT f.title, c.name, f.rental_duration,NTILE(4) OVER ( ORDER BY f.rental_duration) standard_quartile
FROM category c
JOIN film_category fc
ON c.category_id = fc.category_id
JOIN film f
ON f.film_id = fc.film_id
WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music'));

SELECT standard_quartile, name, COUNT(*) COUNT
FROM CTE_customers
GROUP BY 2, 1
ORDER BY 2,1

/* Query 4 for Fourth visual- From Set 2 Question 2 */
/*Query to capture the customer name, month, and year of payment, and total payment amount for each month by these top 10 paying customers*/

SELECT DATE_TRUNC('month', p.payment_date) AS pay_mon, CONCAT(c.first_name,' ', c.last_name) AS fullname, 
COUNT(p.amount) AS pay_countpermon, SUM(p.amount) AS pay_amount
FROM customer c
JOIN payment p ON p.customer_id = c.customer_id
WHERE c.last_name IN (SELECT t1.last_name FROM (SELECT c.last_name, SUM(p.amount)
	FROM customer c
	JOIN payment p
	ON p.customer_id = c.customer_id
	GROUP BY 1 ORDER BY 2 DESC LIMIT 10) t1);
	GROUP BY fullname, pay_mon
	BY fullname, pay_mon, pay_countpermon
