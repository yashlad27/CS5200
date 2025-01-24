
-- start by creating a database named student 
CREATE DATABASE student_db;
-- what happens if I try to create it again 
CREATE SCHEMA student_db;
-- to avoid the error, review the IF NOT EXISTS clause 
CREATE SCHEMA IF NOT EXISTS student_db;


-- set your default database using the USE command
-- if no database is specified SQL uses the default value for all the commands that follow 
USE student_db; 

/* Syntax for the CREATE TABLE command
   CREATE TABLE table_name 
   ( field1 field1_type field_constraint [, field2 field2_type ...);
*/

/* What are the field constraints in MySQL? */
/* UNIQUE, NOT NULL, PRIMARY KEY,AUTO_INCREMENT
 * some require a value like DEFAULT default_value
 
/* You can also express table constraints for a table
   CREATE TABLE name(field1 field_type1 field1_attributes 
[, field2 field_type2 field2_attributes ]
[, table_constraints ] ) ;
 Table constraints limit the table
 */ 
 

-- CREATE a base table for Student
-- LET'S SAY WE WANT TO CREATE A TABLE THAT CONTAINS THE FIELDS: STUDENT_ID,
-- FIRST_NAME, LAST_NAME, SCHOOL, CREDITS_EARNED, CREDIT_REQ, DATE OF BIRTH
-- let's claim name needs a value, student_id is the primary key, and we
-- are putting a constraint on the date of birth to be afterr 1/1/1900
-- another constraint we have is that the class value cannot be >- 2050

CREATE TABLE college (
id INT AUTO_INCREMENT PRIMARY KEY,
college_name VARCHAR(30) UNIQUE NOT NULL 
);

INSERT INTO college (college_name)
	VALUES ("Khoury"),
			("COE");

CREATE TABLE student (
nuid INT AUTO_INCREMENT PRIMARY KEY, 
first_name VARCHAR(100) NOT NULL,
last_name VARCHAR(100) NOT NULL,
credit_earned INT DEFAULT 0,
credit_required INT NOT NULL,

school INT, 

date_of_birth DATE NOT NULL CHECK(date_of_birth >= '1900-01-01'),
class YEAR NOT NULL CHECK(class >= 1920),

FOREIGN KEY (school) REFERENCES college(id) ON UPDATE CASCADE ON DELETE RESTRICT 
);

-- Now drop the table using the DROP TABLE command
DROP TABLE student;
-- recreate the table but make sure your GENERAL constraints are named 
-- we can also provide a name for the general constraint 
/* create a general using CONSTRAINT keyword constraints

*/ 
CREATE TABLE student (
nuid INT AUTO_INCREMENT PRIMARY KEY, 
first_name VARCHAR(100) NOT NULL,
last_name VARCHAR(100) NOT NULL,
credit_earned INT DEFAULT 0,
credit_required INT NOT NULL,
date_of_birth DATE NOT NULL,
class YEAR NOT NULL,
CONSTRAINT birth_constraint CHECK(date_of_birth >= '1900-01-01'),
CONSTRAINT class_constraint CHECK(class >= 1920)
);

DROP TABLE student;
DROP VIEW teacher_view;
-- let's create  a teacher view of the student table 
-- teachers should only have access to the student_id, first_name, and last_namme of the student 
-- view of the table 

CREATE VIEW teacher_view AS SELECT nuid, first_name, last_name FROM student; 
-- insert tuples into the table - we specify the names of the fields
-- then specify the values, each tuple in its own parentheses 
INSERT INTO     
Student(first_name , last_name , 
	school, credit_earned, credit_required, 
	date_of_birth , class)    
VALUES 
('Lucy', 'Liu' , 1, 20, 128, '2004-12-22', '2022'),    -- note the date format
('Matt', 'Finn', 2, 24, 128, '2006-07-04', '2022'),    
('Sam', 'Asner', 1, 32, 120, '2005-03-14', '2022');

-- now let's determine the tables needed to represent the relationship between 
-- a student declares a major 
-- a student has 0 to many majors and a major has 0 to many students 
-- what type of relationship is this?
-- how many tables do we need. 
-- now let's create a table for the majors offered at Northeastern 

CREATE TABLE available_major(
NAME VARCHAR(36) PRIMARY KEY
);
  
CREATE TABLE course(
NAME VARCHAR(64) PRIMARY KEY
); 

  -- We also need an association table between major and student 
-- linking together major and student                      
CREATE TABLE student_major(
nuid INT,
major VARCHAR(36),
PRIMARY KEY (nuid, major)
);

                
-- INSERT into the available_major table                
INSERT INTO available_major VALUES
               ('CS'), ('Accounting'), ('DS');
               
-- INSERT data into the student_major table
INSERT INTO student_major VALUES 
                (1,'CS'),
				(1,'Accounting'), 
				(2,'CS'), 
				(3, 'DS');
-- Create a view on the student table of CS majors 

INSERT INTO student_major VALUES
(1, 'DS'); 

-- Will the following command succeed?
--  INSERT INTO student_major VALUES
-- (6, 'DS');  

  

/* what if we wanted to represent the registers relationship 
 * between student and courses
 * we need to look at the multiplicities to determine how to
   represent it. A student can register for 0 to many courses
   a course is registered by 1 to many courses. Since both sides 
   have a cadninalty of many it is a *:* relationship. We need a 
   separate table to represent a *:* relationship
   We need to determine the PRIMARY KEY, FOREIGN keys
*/
 

/* next we need to represent that registers.cid and registers.sid 
   should be limitied to the values in course.cid and student.sid
   do you remember how we do this? 
*/


/* we need a foreign key - actually we need 2 foreign keys - so
   lets create them there are 2 different methods for 
   representing foreign keys, in one method you use the
   CONSTRAINT key word, this allows you to specify a name for
   the foreign key. The other method you do not provide a name */



/* We can also express what behavior we want to happen if there 
   is a change to the parent tuple that would violate the FK
   what change should be made to the child tuple to ensure referential
   integrity? 
   We use the ON UPDATE and ON DELETE clause for the FK to
   specify the behavior we want
   What actions can violate the FK?
*/

                      