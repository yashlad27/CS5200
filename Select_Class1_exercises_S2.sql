/* the syntax for the SELECT command
SELECT field_list
FROM table
WHERE condition_true  ORDER BY order_field_list  LIMIT num_tuples;

*/
USE AP;

/* let's walk through some commands that we have 
   Covering Chapter 3, 4, 6 in Murach's MySQL
   
*/
-- simple SELECT to extract a subset of the columns 
-- invoice_id, invoice_date and invoice_total from the invoices

SELECT invoice_id, invoice_date, invoice_total from invoices;
-- 114 rows 

SELECT * FROM invoices; -- 114 tuples 


-- we can do computations on the fields returned to change the value returned
-- let's return the invoice_id, the invoice date, the invoice_due_date report on
-- amount still owed on the invoice

SELECT invoice_id, invoice_due_date, invoice_total - payment_total - credit_total 
  from invoices; 

-- the name of that column is a bit ugly - we can use the AS keyword
-- to give it a better name

   -- we can alias or use AS for any field 
  SELECT invoice_id, invoice_due_date, 
          invoice_total - payment_total - credit_total AS amount_owed
  from invoices;  
   
   -- LET's order the invoices by amount owed
   
    SELECT invoice_id, invoice_due_date, 
          invoice_total - payment_total - credit_total AS amount_owed
  from invoices order by amount_owed ASC ;
  
   -- defaults to ASC or ascending order
     SELECT invoice_id, invoice_due_date, 
          invoice_total - payment_total - credit_total AS amount_owed
  from invoices order by amount_owed DESC, payment_date asc ;    
     
-- YOU CAN ORDER BY MORE THAN 1 FIELD

-- Let's look at the LIMIT CLAUSE
-- we can use it determine the max # of tuples to be returned
     SELECT invoice_id AS invoice, invoice_due_date, 
          invoice_total - payment_total - credit_total AS amount_owed
  from invoices order by amount_owed desc
      limit 5, 10;  
 
 -- WHERE TO START;
 
 -- LET'S SAY I WANT ALL OF THE VENDOR IDS FROM THE INVOICES TABLE
 SELECT vendor_id FROM invoices ORDER BY vendor_id ;
 
 -- is the result of this a relation?
 -- no 
 
 SELECT distinct vendor_id FROM invoices ORDER BY vendor_id ;
 -- 34 rows 
 
 -- now let's limit results by values in the tuples
 -- we use the WHERE clause to do this
 -- return information for vendor_id 7
 
 SELECT * FROM vendors WHERE vendor_id = 7;
 -- where operators < <= > >= = != <> BETWEEN LIKE 
 
 
 
 -- WRITE A QUERY THAT RETURNS ALL VENDORS FROM THE VENDOR TABLE 
 -- WHERE THE VENDOR_ID IS BETWEEN 7 AND 20
 
 select * from vendors where vendor_id >= 7 AND vendor_id <= 20;
 
 -- AND KEYWORD is SQL STANDARD  '&&' is MySQL specific they are equivalent 
 -- we can rewrite this query using the BETWEEEN keyword
select * from vendors where vendor_id BETWEEN 7 AND 20;

-- What if I wanted to find all vendors from MA or CT
select * from vendors WHERE vendor_state = 'MA' OR vendor_state = 'CT';

-- I can also rewrite this to use the IN keyword
SELECT * FROM vendors WHERE vendor_state IN ('MA', "CT");

-- NEGATE THE OPERATION
SELECT * FROM vendors WHERE vendor_state NOT IN ('MA', "CT"); -- 118 
-- WRITE A QUERY THAT RETURNS ALL VENDORS NOT FROM NEW ENGLAND

SELECT * FROM vendors where vendor_state not in ('ct', 'ma', 'me', 'ri', 'nh', 'vt'); -- 118

SELECT * FROM vendors where vendor_state in ('ct', 'ma', 'me', 'ri', 'nh', 'vt'); -- 4 

SELECT * FROM vendors; -- 122 rows 


-- What if I wanted all vendors whose name begins with A?
-- pattern matching in standard sql 
-- simple regular expression
-- like 
-- any character to match itself
-- % matches 0 or more characters
-- _ matches exactly 1 character 

SELECT * FROM vendors WHERE vendor_name LIKE 'a_e%s';

-- DO I NEED TO CAPTILIZE THE A ?
-- not necessary to specify the case that is stored in the DB

-- aggregation
-- We can create aggregate queries that perform a function across tuples
-- the SQL standard operations we can perform are SUM, COUNT, MIN, MAX, AVG 
-- SELECT operation(field) FROM table;
-- find the amount paid for invoices 

select sum(payment_total), min(invoice_date), min(payment_total)   AS amount_paid FROM invoices; 

select invoice_id, vendor_id from invoices;
-- COUNT operator 
select count(*) from invoices; -- 114 tuples

select count(vendor_id) from invoices; -- 114 tuples have vendors 
select count(invoice_id) FROM invoices; -- 114 tuples 

select count(payment_date) from invoices; -- 103 tuples have a payment date 

select count(distinct vendor_id) from invoices; -- 34 

-- all cities for a particular vendor state:
SELECT vendor_state, group_concat(vendor_city) FROM vendors GROUP by vendor_state;
SELECT DISTINCT vendor_state FROM vendors;

select group_concat(distinct vendor_state) AS vendor_states from vendors; 

select sum(payment_total) AS paid_to_me FROM invoices;

-- GROUP BY keyword 
-- it returns a single value for use
-- what if I wanted payment_total by the vendors 
-- I can use the GROUP BY clause to GROUP the invoices into groups 
-- groups are defined by the values of a specific field

select vendor_id, sum(payment_total) AS vendor_total , 
                  sum(invoice_total) AS amount_owed -- 34 rows 
    FROM invoices GROUP BY vendor_id; 

-- Error Code: 1054. Unknown column 'amount_owed_vendor' in 'where clause'
    
select vendor_id,
		sum(invoice_total) - sum(payment_total) AS amount_owed_vendor
    FROM invoices 
    WHERE credit_total > 0 
    GROUP BY vendor_id HAVING amount_owed_vendor > 0 
    ORDER BY amount_owed_vendor DESC ; 
    
-- Now let's say you are only interested in reporting vendors where the sum of the payment
-- is greater than $800 - you want to apply a filter to the results we just generated
-- the HAVING clause allows you to filter an AGGREGATED RESULT
SELECT vendor_id, SUM(payment_total) AS payment_from_vendor 
FROM invoices GROUP BY vendor_id HAVING payment_from_vendor > 800
ORDER BY payment_from_vendor DESC;
  
  -- MYSQL does have an additional aggregate function called group_concat - 
  -- it produces a comma separate list of a string 
  
  -- keywords for extracting from multiple tables: 
	
  
-- So far we have been generating information from 1 table 
-- but useful information is across multiple tables
-- this schema seems to have some redundancy 
-- what if I want vendor contacts - it looks like I have this
-- information in the vendors table and the vendor contacts table
SELECT vendor_id, last_name, first_name FROM vendor_contacts ORDER BY vendor_id;

-- 8 tuples

-- I CAN ALSO WRITE THE same query for the vendors table

SELECT vendor_id, vendor_contact_last_name, vendor_contact_first_name 
FROM vendors ORDER BY vendor_id;  -- 122 tuples

-- WHAT I WANT TO DO IS GLUE THESE 2 RESULTS TOGETHER
-- union OPERATION DOES THIS FOR ME
SELECT vendor_id, last_name, first_name FROM vendor_contacts 
UNION SELECT vendor_id, vendor_contact_last_name, vendor_contact_first_name 
FROM vendors ORDER BY vendor_id;

-- I GET BACK 130 TUPLES so we can look at the duplicates 
-- 1 Select all fields and all tuples from the invoices table
SELECT vendor_id, last_name, first_name FROM vendor_contacts 
UNION ALL
SELECT vendor_id, vendor_contact_last_name, vendor_contact_first_name 
FROM vendors ORDER BY vendor_id;

-- there are no duplicates in this result each tuple was different due to the names

-- but what if there would be duplicates like

-- UNION removes the duplicates - makes sense since it is a SET operation
-- but what if you want the duplicates???
-- use the KEYWORD ALL
SELECT vendor_id FROM vendors 
UNION 
SELECT invoice_id FROM invoices;  -- no sense semantically ? 

-- joins allow us to link tables using Foreign keys

-- we can also use the JOIN operation to pull data from multiple tables
-- what if I want fields from different tables like the invoice total and the vendor name
-- in my result 
-- this is where we take advantage of our foreign keys 
-- SELECE field_list FROM table1 JOIN table2 ON table1.field1 = table2.field2;
-- this is knows as an inner join, we limit our result to tuples that satsfy the
-- ON clause 
SELECT vendor_name, invoice_id, invoice_total, invoice_date 
	FROM invoices JOIN vendors ON invoices.invoice_id = vendors.vendor_id;  -- explicit join

-- verification query
SELECT COUNT(*) FROM invoices; -- 114 invoices

-- what if I wanted vendor_id in the result? can I just add it to the field list
SELECT vendor_name, vendors.vendor_id, invoice_id, invoice_total, invoice_date 
	FROM invoices JOIN vendors ON invoices.vendor_id = vendors.vendor_id;
    
-- NO I generate an error need the table name to disambiguate the field 
SELECT vendor_name, vendors.vendor_id, invoice_id, invoice_total, invoice_date 
	FROM invoices JOIN vendors USING(vendor_id);
    
-- what happens if I forget the ON clause let's do it between the vendor and the
-- vendor_contacts table
SELECT vendor_name, vendors.vendor_id, invoice_id, invoice_total, invoice_date 
	FROM invoices JOIN vendors;

SELECT vendor_name, vendors.vendor_id, invoice_id, invoice_total, invoice_date 
	FROM invoices CROSS JOIN vendors;
    
    SELECT vendor_name, vendors.vendor_id, invoice_id, invoice_total, invoice_date 
	FROM invoices INNER JOIN vendors;
    
-- CROSS PRODUCT FOR EACH TUPLE IN ONE TABLE 
-- Implicit join
-- NOW there is another way to express a JOIN - the old fashion syntax
-- SELECT fieldlist FROM tablelist WHERE to restrict tuples;
SELECT vendor_name, vendors.vendor_id, invoice_id, invoice_total, invoice_date 
	FROM invoices, vendors
    WHERE invoices.vendor_id = vendors.vendor_id; 
    
SELECT vendor_name, SUM(invoice_total) AS vendor_total
FROM invoices INNER JOIN vendors ON vendors.vendor_id = invoices.vendor_id
GROUP BY vendor_name;

SELECT vendor_name, SUM(invoice_total) AS vendor_total
FROM invoices RIGHT OUTER JOIN vendors ON vendors.vendor_id = invoices.vendor_id
GROUP BY vendor_name;

SELECT vendor_name, SUM(invoice_total) AS vendor_total
	FROM invoices, vendors WHERE vendors.vendor_id = invoices.vendor_id
	GROUP BY vendor_name;
    
SELECT vendor_name FROM invoices, vendors WHERE vendors.vendor_id = invoices.vendor_id
GROUP BY vendor_name;

  -- I get the same result as the result where I use the JOIN key word
  -- this is known as an implicit JOIN when you use the KEYWORD JOIN
  -- that is known as an explicit JOIN
  -- INDUSTRY EXPLECTS EXPLICIT JOINS 
  
  -- EXPLICIT JOINS 
  -- money gotten from vendors we would use our JOIN construct to
  -- report on vendors 

  
  -- rach tuple in the OUTER table must appear in my result 
  
  
  -- THE VALUES FOR THE FIELDS FROM THE TABLE WITHOUT A MATCH ARE SET TO null 
  -- now what if I just want the vendors who have no invoices
  
  
  -- there is also something known as a NATURAL JOIN 
 SELECT vendor_name, invoice_total, invoice_date FROM invoices NATURAL JOIN vendors; -- no need to specify the predicate 
 
  -- what is different in the structure of the result ??
  SELECT * FROM invoices NATURAL JOIN vendors;
  
  SELECT * FROM invoices INNER JOIN vendors ON vendors.vendor_id = invoices.vendor_id;
  

-- Count the number of vendors  assign the result to a variable names num_vendors (AGGREGATION )
-- Count the number of invoices per vendor 
-- Calculate the total payment by vendor, return the vendor name and the total
-- Calculate the total payment by vendor, return the vendor id  and the total payment for vendor for vendors who paid more than $100
SELECT COUNT(vendor_id) FROM vendors;
SELECT COUNT(invoice_id) FROM invoices;


