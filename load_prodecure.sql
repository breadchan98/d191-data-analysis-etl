CREATE OR REPLACE PROCEDURE new_detailed_table()
	LANGUAGE plpgsql
	AS $$
	BEGIN
		DELETE FROM detailedtableset;
		INSERT INTO detailedtableset (
			name,
			title,
			amount,
			address,
			first_name,
			last_name
		)
		SELECT 
			name, 
			title,
			amount,
			address,
			customer.first_name,
			customer.last_name
		FROM category
		INNER JOIN film_category
			ON category.category_id = film_category.category_id
		INNER JOIN film
			ON film_category.film_id = film.film_id
		INNER JOIN inventory
			ON film.film_id = inventory.film_id
		INNER JOIN rental
			ON inventory.inventory_id = rental.inventory_id
		INNER JOIN payment
			ON rental.rental_id = payment.rental_id
		INNER JOIN customer
			ON payment.customer_id = customer.customer_id
		INNER JOIN staff
			ON payment.staff_id = staff.staff_id
		INNER JOIN store
			ON staff.store_id = store.store_id
		INNER JOIN address
			ON store.address_id = address.address_id
		INNER JOIN city
			ON address.city_id = city.city_id
		INNER JOIN country
			ON city.country_id = country.country_id;
	END;$$