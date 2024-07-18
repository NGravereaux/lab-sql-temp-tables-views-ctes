USE sakila;
-- Step 1: Create a View
-- First, create a view that summarizes rental information for each customer. 
-- The view should include the customer's ID, name, email address, and total number of rentals (rental_count).
CREATE VIEW customer_rental_sum AS
SELECT 
c.customer_id, 
c.first_name, 
c.last_name, 
c.email, 
COUNT(r.rental_id) AS rental_count
FROM customer AS c
JOIN rental AS r ON c.customer_id = r.customer_id
GROUP BY 
    c.customer_id
ORDER BY 
    rental_count DESC;

-- call the view
SELECT * FROM customer_rental_sum;

-- Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
-- The Temporary Table should use the rental summary view created in Step 1 to join with the payment table 
-- and calculate the total amount paid by each customer.
CREATE TEMPORARY TABLE customer_total_paid AS
SELECT
crs.customer_id,
crs.first_name,
crs.last_name,
crs.email,
SUM(p.amount) AS total_paid
FROM customer_rental_sum AS crs
JOIN payment AS p ON crs.customer_id = p.customer_id;

-- call the table 
SELECT * FROM customer_total_paid;

-- Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
-- The CTE should include the customer's name, email, rental count, and total amount paid.
-- Next, using the CTE, create the query to generate the final customer summary report, 
-- which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, 
-- this last column is a derived column from total_paid and rental_count.
WITH customer_summary_cte AS 
(SELECT 
crs.customer_id,
crs.first_name,
crs.last_name,
crs.email,
crs.rental_count,
ctp.total_paid
FROM customer_rental_sum AS crs
JOIN customer_total_paid AS ctp ON crs.customer_id = ctp.customer_id)
SELECT 
*,
ROUND(total_paid / rental_count, 2) AS average_payment_per_rental
FROM customer_summary_cte
ORDER BY 
    rental_count DESC;
;
