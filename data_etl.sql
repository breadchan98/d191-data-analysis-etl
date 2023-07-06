/* Pulls data from the database and casted into detailed table */
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
		
---------------------------------------
/* Creation of detailedtableset, IF NOT EXISTS applied */		
DROP TABLE IF EXISTS detailedTableSet;
CREATE TABLE IF NOT EXISTS detailedtableset (
	name VARCHAR(50), 
	title VARCHAR(50),
	amount DECIMAL(10,2),
	address VARCHAR(50),
	first_name VARCHAR(50),
	last_name VARCHAR(50)
);

/* Creation of summarytableset, IF NOT EXISTS applied */
DROP TABLE IF EXISTS summarytableset;
CREATE TABLE IF NOT EXISTS summarytableset (
	address_location VARCHAR(50),
	name VARCHAR(20),
	category_overall_price VARCHAR(20),
	category_sales_count INT
);

----------------------------------------
/*
The field is transforming the amount DATA TYPE INT from the detailed table set to a VARCHAR data type, in order to
concat it with a string, "$", notifying the business that the field "category_overall_price" is the total amount of category sales.
*/

CREATE OR REPLACE FUNCTION int_var_convert()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN

--Clear out Summary Table
DELETE FROM summarytableset;
--Concat address, city, and country to clean out data layout and make it easily readible
INSERT INTO summarytableset (
	SELECT
		address AS "address_location",
		name,
		concat('$', TO_CHAR(SUM(amount)::numeric, '9999999999.99')) AS "category_overall_price",
		COUNT(name) AS "category_sales_count"
	FROM detailedtableset
	GROUP BY address_location, name
	ORDER BY address_location, category_overall_price DESC
	);
RETURN NEW;
END;$$

-------------------------------------------

/* This will be applied ONLY when data is inserted into the database and into the detailed table set*/

CREATE TRIGGER alter_summary
AFTER INSERT ON detailedtableset
--only execution on a new row without reruning data query
FOR EACH STATEMENT 
EXECUTE PROCEDURE int_var_convert()
	
	--------------------------------------
	
	/* This will refresh the detailed table set by removing the previous data and replacing it with new data.
	This should be applied every month, as new films per category are newly produced and sent to store shelves */
	
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
