-- initialize the db
USE sakila;

-- Step 1: Create a View... 
-- that summarizes rental information for each customer.
-- The view should include the customer's ID, name, email address, 
-- and total number of rentals (rental_count). -> count rental_id grouped by cust_id
DROP TEMPORARY TABLE if exists sakila.temp_tbl_cust_payment_sum;
DROP VIEW if exists sakila.vw_rental_summary;

create view sakila.vw_rental_summary as
SELECT
	c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    COUNT(r.rental_id) AS 'rental_count'
FROM sakila.customer as c
JOIN sakila.rental AS r
	ON c.customer_id = r.customer_id
GROUP BY c.customer_id;


-- Step 2: Create a Temporary Table...
-- that calculates the total amount paid by each customer (total_paid). 
-- The Temporary Table should use the rental summary view created in Step 1 to join 
-- with the payment table and calculate the total amount paid by each customer.
CREATE TEMPORARY TABLE sakila.temp_tbl_cust_payment_sum
SELECT
	c.customer_id,
	SUM(p.amount) AS 'total_paid' 
FROM sakila.vw_rental_summary as c
JOIN sakila.rental AS r
	ON c.customer_id = r.customer_id
JOIN sakila.payment AS p
	ON r.rental_id = p.rental_id
GROUP BY c.customer_id;


-- Step 3: Create a CTE and the Customer Summary Report...
-- that joins the rental summary View with the customer payment summary Temporary Table 
-- created in Step 2. The CTE should include the customer's 
-- name, email address, rental count, and total amount paid.
WITH cte_example AS (
	SELECT
		c.*,
        p.total_paid
	FROM sakila.vw_rental_summary as c
	JOIN sakila.temp_tbl_cust_payment_sum AS p
		ON c.customer_id = p.customer_id
)
SELECT 
	e.first_name,
    e.last_name,
	e.email,
    e.rental_count,
    e.total_paid,
    e.total_paid / e.rental_count as 'average_payment_per_rental'
FROM cte_example AS e;







