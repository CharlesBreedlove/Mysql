use sakila; 

SELECT first_name, last_name FROM actor;


-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select first_name, last_name,CONCAT(first_name,' ',last_name) AS full_name FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT * FROM actor WHERE first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT * FROM actor WHERE last_name LIKE '%GEN%' ;

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT * FROM actor 
	WHERE last_name LIKE '%LI%' 
	ORDER BY last_name, first_name ASC;
 
-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select * from country
	WHERE Country IN ("Afghanistan", "Bangladesh", "china");

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
ALTER TABLE actor
ADD COLUMN middle_name VARCHAR(50);
select first_name, middle_name, last_name from actor;


-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
ALTER TABLE actor DROP middle_name;
alter table actor add column middle_name blob;

-- 3c. Now delete the middle_name column.
ALTER TABLE actor DROP middle_name;


-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(*) AS 'Number_of_Actors'
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, count(*) AS 'number_of_actors'
FROM actor
GROUP BY last_name
having number_of_actors > 1;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
UPDATE actor
SET first_name = REPLACE(first_name,'GROUCHO','HARPO')
WHERE first_name = 'GROUCHO' and last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)
-- figure out latter
select *,
if (first_name = 'HARPO','GROUCHO','MUCHO GROUCHO') 
as 'nickname'
from actor
where actor_id = '172';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT staff.first_name, staff.last_name, address.address
FROM staff
INNER JOIN address ON
staff.address_id=address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT staff.first_name, staff.last_name, sum(payment.amount) as 'sum'
FROM staff
INNER JOIN payment ON
staff.staff_id=payment.staff_id
GROUP BY last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT film.title, count(film_actor.film_id) as 'count'
FROM film_actor
INNER JOIN film ON
film.film_id=film_actor.film_id
GROUP BY title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select count(*) as 'Number of Movies in Invetory'
from inventory
where film_id in (
	SELECT film_id 
	FROM film 
	where title like 'Hunchback Impossible'
);

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT customer.first_name, customer.last_name, sum(payment.amount) as 'total_paid'
FROM customer
INNER JOIN payment ON
customer.customer_id=payment.customer_id
GROUP BY last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select title
from film
where (title like 'k%' or title like 'q%') and language_id in 
	(
	select language_id
	from language
    where name = 'English'
);

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select first_name, last_name 
from actor
where actor_id in (
	select actor_id
	from film_actor
	where film_id in (
		select film_id
		from film
		where title = 'Alone Trip'
		)
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT customer.first_name, customer.last_name, customer.email, address.address_id, city.city_id, country.country
FROM customer
INNER JOIN address ON
customer.address_id=address.address_id
inner join city on 
city.city_id=address.city_id
inner join country on 
country.country_id=city.country_id
where country.country = 'Canada'
;

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.
select title
from film
where film_id in (
	select film_id
	from film_category
	where category_id in (
		SELECT category_id
		FROM category
		where name = 'Family'
		)
	);

-- 7e. Display the most frequently rented movies in descending order.
select film.title, count(film.title) as 'film_count'
from inventory
INNER JOIN film ON
inventory.film_id=film.film_id
group by film.film_id 
order by film_count DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select store.store_id, sum(payment.amount)
from payment
inner join staff on
payment.staff_id = staff.staff_id
inner join store on
store.store_id = staff.store_id
group by store.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select store.store_id, city.city, country.country
from store
inner join address on
store.address_id = address.address_id
inner join city on
address.city_id = city.city_id
inner join country on
city.country_id = country.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select  category.name, sum(payment.amount) as 'gross'
from category
inner join film_category on
film_category.category_id = category.category_id
inner join film on 
film.film_id = film_category.film_id
inner join inventory on 
inventory.film_id = film.film_id
inner join rental on
rental.inventory_id = inventory.inventory_id
inner join payment on
payment.rental_id = rental.rental_id
group by category.name
order by gross desc
limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW `Top_5_Catagories` AS
select  category.name, sum(payment.amount) as 'gross'
from category
inner join film_category on
film_category.category_id = category.category_id
inner join film on 
film.film_id = film_category.film_id
inner join inventory on 
inventory.film_id = film.film_id
inner join rental on
rental.inventory_id = inventory.inventory_id
inner join payment on
payment.rental_id = rental.rental_id
group by category.name
order by gross desc
limit 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM Top_5_Catagories;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW `Top_5_Catagories`;