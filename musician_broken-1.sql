
CREATE DATABASE notown3;
USE notown3;

CREATE TABLE musician_address
( ssn INT PRIMARY KEY,
  name VARCHAR(64) NOT NULL,
  phone CHAR(11),
  street VARCHAR(64) NOT NULL ,
  city VARCHAR(64) NOT NULL,
  state CHAR(2) NOT NULL,
  zipcode char(5) NOT NULL
  );
  
  /* let say I am tracking 3 or more 
      musicians that live in the same address */
  
  INSERT INTO musician_address VALUES 
  (1, "JAY-Z", "5555555555", "181 MAIN" ,"BROOKLYN", "NY", "11223");
  
  INSERT INTO musician_address VALUES 
  (2, "Beyonce", "5555555555", "181 MAIN" ,"BROOKLYN", "NY", "11223");
  
  INSERT INTO musician_address VALUES 
  (3, "Blue Ivy", "5555555555", "181 MAIN" ,"BROOKLYN", "NY", "11223");
  
  INSERT INTO musician_address VALUES 
  (4, "Sir", "5555555555", "181 MAIN" ,"BROOKLYN", "NY", "11223");
  
  -- What prevents me from UPDATING Beyonce's address without updating Jay-Z's ADDRESS? 
  
  SELECT * from musician_address; 
  
  -- modification anomaly 
  UPDATE musician_address SET zipcode = "02215" WHERE ssn = 1; 
  
  UPDATE musician_address SET phone = "66666666666" WHERE ssn = 2; 
  
  SELECT * from MUSICIAN_ADDRESS;
  
  -- insert anomaly 
  INSERT INTO musician_address VALUES 
  (5, "Rumi", "5555555555", "181 MAIN" ,"Manhattan", "NY", "11223");
  -- lost not just the musicians but also the phone number
  -- and address association
  
  -- deletion anomaly 
  DELETE FROM musician_address
   where  ssn < 10;
  
