-- 1 Вывести количество фильмов в каждой категории, отсортировать по убыванию.

SELECT COUNT(f.film_id) AS films_in_cat,   -- 'counting films by category'
	   c."name" 
FROM film f    				-- 'Using table film'
INNER JOIN film_category fc ON f.film_id = fc.film_id   -- 'adding table film_category to get the id of category name'
INNER JOIN category c ON fc.category_id = c.category_id  -- 'adding table category table to get the name of category'
GROUP BY c."name"
ORDER BY films_in_cat DESC;  -- 'ordering by descending order'


-- 2 Вывести 10 актеров, чьи фильмы большего всего арендовали, отсортировать по убыванию.

SELECT CONCAT_WS(' ', COALESCE(a.first_name, ''), COALESCE(a.last_name, '')) AS actor_name,  -- 'Searching for NULL values and changing them to '' ' 
		(r.return_date - r.rental_date) AS rental_duration  
FROM actor a
INNER JOIN film_actor fa ON fa.actor_id = a.actor_id   -- 'Joining other tables to get to the rental table'
INNER JOIN film f ON f.film_id = fa.film_id
INNER JOIN inventory i ON i.film_id = f.film_id 
INNER JOIN rental r ON r.inventory_id = i.inventory_id
WHERE r.return_date IS NOT NULL AND r.rental_date IS NOT NULL   -- 'Avoiding NULL values in result'
ORDER BY rental_duration DESC		-- 'Ordering descendig way'
LIMIT 10;   -- 'Limiting result to 10 lines'


-- 3 Вывести категорию фильмов, на которую потратили больше всего денег.

SELECT c."name", 
	   SUM(p.amount) AS total_spent   -- 'SUM of the payments for each rent'
FROM category c
INNER JOIN film_category fc ON c.category_id = fc.category_id   -- 'Joining other tables to get the payment amount'
INNER JOIN film f ON fc.film_id  = f.film_id 
INNER JOIN inventory i ON f.film_id = i.film_id 
INNER JOIN rental r ON i.inventory_id = r.inventory_id 
INNER JOIN payment p ON r.rental_id = p.rental_id 
GROUP BY c."name"					-- 'GROUPING category'
ORDER BY total_spent DESC -- 'Ordering by DESCINDING order'
LIMIT 1;  -- 'To get only 1 result row'

-- 4 Вывести названия фильмов, которых нет в inventory. Написать запрос без использования оператора IN.

SELECT f.film_id, 
	   f.title 
FROM film f 
LEFT JOIN inventory i ON f.film_id = i.film_id    -- 'Take all films and add everithing that match also added NULLS where not matched'
WHERE i.film_id IS NULL   -- 'Filtering all that not matched'
ORDER BY f.title;   -- 'Ordering ASCending by name'

/*              -- 'CHECK'
SELECT *
FROM inventory i 
WHERE i.film_id = 33
*/  -- NONE



-- 5 Вывести топ 3 актеров, которые больше всего появлялись в фильмах в категории “Children”. 
--   Если у нескольких актеров одинаковое кол-во фильмов, вывести всех.

SELECT CONCAT_WS(' ', COALESCE(a.first_name, ''), COALESCE(a.last_name, '')) AS actor_name,  -- 'avoiding NULL's'
	   COUNT(c."name")  AS Played_children_films
FROM actor a 
INNER JOIN film_actor fa ON a.actor_id = fa.actor_id  -- 'Joining tables to get all needed information'
INNER JOIN film f ON fa.film_id = f.film_id
INNER JOIN film_category fc ON f.film_id = fc.film_id 
INNER JOIN category c ON fc.category_id = c.category_id
WHERE UPPER(c."name") = 'CHILDREN'
GROUP BY c."name", a.actor_id
ORDER BY Played_children_films DESC
FETCH FIRST 3 ROWS WITH TIES;          -- 'Selecting ALL actors with the same quantity of played Chilndren films'

-- 6 Вывести города с количеством активных и неактивных клиентов (активный — customer.active = 1). 
-- Отсортировать по количеству неактивных клиентов по убыванию.

SELECT c.city, 
	   c2.active AS is_active,
	   COUNT(c2.active) AS count_activity_by_city  -- 'Counting atvive/inactive clients per city'
FROM city c
INNER JOIN address a ON c.city_id = a.city_id 
INNER JOIN customer c2 ON a.address_id = c2.address_id
GROUP BY c2.active, c.city
ORDER BY is_active ASC, count_activity_by_city DESC;  -- 'Firstly ordering by inactive (by ZERO is ASC) after count DESC'


-- variant 2
SELECT c.city,
       SUM(CASE WHEN c2.active = 1 THEN 1 ELSE 0 END) AS active_customers,
       SUM(CASE WHEN c2.active = 0 THEN 1 ELSE 0 END) AS inactive_customers
FROM city c
INNER JOIN address a ON c.city_id = a.city_id 
INNER JOIN customer c2 ON a.address_id = c2.address_id
GROUP BY c.city
ORDER BY inactive_customers DESC;

-- 7 Вывести категорию фильмов, у которой самое большое кол-во часов суммарной аренды в городах (customer.address_id в этом city), 
-- и которые начинаются на букву “a”. То же самое сделать для городов в которых есть символ “-”. Написать все в одном запросе.

SELECT c."name",
	   ROUND(EXTRACT(DAY FROM (r.return_date - r.rental_date)) * 24 +  -- 'Collecting hours from date diff and round it'
	   EXTRACT(HOUR FROM (r.return_date - r.rental_date)) + 
	   EXTRACT(MINUTE FROM (r.return_date - r.rental_date)) / 60) AS rental_duration_in_hours,
	   c3.city
	   
FROM category c   -- 'join tables'
INNER JOIN film_category fc ON c.category_id  = fc.category_id 
INNER JOIN film f ON fc.film_id  = f.film_id 
INNER JOIN inventory i ON f.film_id  = i.film_id 
INNER JOIN rental r ON i.inventory_id = r.inventory_id
INNER JOIN customer c2 ON r.customer_id = c2.customer_id 
INNER JOIN address a ON c2.address_id = a.address_id 
INNER JOIN city c3 ON a.city_id = c3.city_id
WHERE (r.return_date IS NOT NULL AND r.rental_date IS NOT NULL   -- 'we avoid null values and filter condition'
	   AND c3.city ILIKE  'a%')
	OR (r.return_date IS NOT NULL AND r.rental_date IS NOT NULL  -- 'OR adds another conditiond'
	   AND c3.city ILIKE  '%-%')
ORDER BY rental_duration_in_hours DESC;


