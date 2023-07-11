/* Transformation Field: Conversion and Aggregation */

CREATE OR REPLACE FUNCTION int_to_char()
RETURN TRIGGER
LANGAUGE plpgsql
AS $$
BEGIN

--Clear summary table
DELETE summary_table_set;

--Insert new data from refreshed detailed to summary
INSERT INTO summary_table_set (
    SELECT
        address AS "address_location",
        name,
        concat('$', TO_CHAR(SUM(amount)::numeric, '99999999.99')) AS "category_overall_price",
        COUNT(name) AS "category_sales_count"
    FROM detailed_table_set
    GROUP BY address_location, name
    ORDER BY address_location, category_overall_price DESC
);
RETURN NEW;
END;$$