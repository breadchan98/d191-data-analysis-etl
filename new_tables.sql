DROP TABLE IF EXISTS detailed_table_set;
CREATE TABLE IF NOT EXISTS detailed_table_set
(
    name VARCHAR(50), 
	title VARCHAR(50),
	amount DECIMAL(10,2),
	address VARCHAR(50),
	first_name VARCHAR(50),
	last_name VARCHAR(50)
);

DROP TABLE IF EXISTS summary_table_set;
CREATE TABLE IF NOT EXISTS summary_table_set (
	address_location VARCHAR(50),
	name VARCHAR(20),
	category_overall_price VARCHAR(20),
	category_sales_count INT
);
