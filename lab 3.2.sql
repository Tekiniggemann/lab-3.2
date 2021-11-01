-- 1. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT *, COUNT(inventory_id) AS Copies
FROM sakila.inventory
WHERE film_id = 439;

SELECT *
FROM sakila.film
WHERE title = 'Hunchback Impossible';


-- 2. List all films whose length is longer than the average of all the films.
select film_id, title, description, length as average_length from sakila.film
where length > (SELECT avg(length)
                FROM sakila.film)
ORDER BY length desc;


-- 3. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT * FROM sakila.actor
WHERE actor_id IN (SELECT actor_id
FROM sakila.film_actor
WHERE film_id = (SELECT film_id FROM sakila.film
WHERE title = 'Alone Trip')
);

-- 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films

FROM sakila.film
WHERE film_id IN (SELECT film_id FROM sakila.film_category
WHERE category_id = (SELECT category_id FROM sakila.category
WHERE name = 'Family')
);


-- 5. Get name and email from customers from Canada using subqueries. 
      -- Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, 
          -- that will help you get the relevant information.
SELECT c.first_name, c.last_name, c.email, cntry.country
FROM sakila.customer c
JOIN sakila.address a
ON c.address_id = a.address_id 
JOIN sakila.city cty
ON cty.city_id = a.city_id
JOIN sakila.country cntry
ON cty.country_id = cntry.country_id
WHERE cntry.country = 'Canada';

select first_name, last_name, email 
from sakila.customer
where address_id in
(select address_id from sakila.address where city_id in
(select city_id from sakila.city where country_id in
(select country_id from sakila.country where country = 'Canada')));

          
          
-- 6. Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. 
      -- First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

SELECT actor_id
FROM sakila.film_actor
GROUP BY actor_id
ORDER BY COUNT(*) DESC
LIMIT 1;

SELECT title
FROM sakila.film
WHERE film_id in (SELECT film_id from sakila.film_actor WHERE actor_id =
(SELECT actor_id FROM sakila.film_actor 
GROUP BY actor_id
ORDER BY COUNT(*) DESC LIMIT 1));

-- 7. Films rented by most profitable customer.
   -- You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments
SELECT *, SUM(amount)
FROM sakila.payment
GROUP BY customer_id
ORDER BY SUM(amount) DESC
LIMIT 1;

SELECT title FROM sakila.film
WHERE film_id IN 
(SELECT film_id FROM inventory 
    WHERE inventory_id IN 
(SELECT inventory_id FROM rental WHERE customer_id = 
(SELECT customer_id FROM payment GROUP BY customer_id ORDER BY SUM(amount) DESC LIMIT 1))
);

-- 8. Customers who spent more than the average payments.

SELECT customer_id, first_name, last_name
FROM sakila.customer
WHERE customer_id IN (SELECT customer_id FROM sakila.payment
GROUP BY customer_id 
HAVING SUM(amount) > (SELECT AVG(TOTAL) FROM
(SELECT customer_id, SUM(amount) TOTAL FROM sakila.payment
GROUP BY customer_id) sb1)
);
