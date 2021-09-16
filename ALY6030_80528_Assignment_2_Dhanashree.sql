# Created a table to store the map cordinates

CREATE TABLE `Housing_DB`.`MapAttributes` (
  `Map_ID` INT NOT NULL AUTO_INCREMENT, #set the constraint for map_id to be non null as this value should never be null but as further I have set this attribute as primary key it automatically considers it as not null.
  `Latitude` DECIMAL(10,8) , # range  value for latitude set as per standard range
  `Longitude` DECIMAL(11,8) , # range  value for longitude set as per standard range
  PRIMARY KEY (`Map_ID`)); # map_id set as the primary key to uniquely identify each row

# Created a table to store the Housing Types

CREATE TABLE `Housing_DB`.`Type` (
  `Type_ID` INT NOT NULL AUTO_INCREMENT, #set the constraint for Type_ID to be non null as this value should never be null but as further I have set this attribute as primary key it automatically considers it as not null.
  `Type` VARCHAR(45) ,
  PRIMARY KEY (`Type_ID`)); # Type_ID set as the primary key to uniquely identify each row

# Created a table to store the State

CREATE TABLE `Housing_DB`.`State` (
  `State_ID` INT NOT NULL AUTO_INCREMENT, ##set the constraint for State_ID to be non null as this value should never be null but as further I have set this attribute as primary key it automatically considers it as not null.
  `State` VARCHAR(20) ,
  PRIMARY KEY (`State_ID`)); # State_ID set as the primary key to uniquely identify each row

# Created a table to store the City

CREATE TABLE `Housing_DB`.`City` (
  `City_ID` INT NOT NULL AUTO_INCREMENT, ##set the constraint for City_ID to be non null as this value should never be null but as further I have set this attribute as primary key it automatically considers it as not null.
  `City_Name` VARCHAR(45) ,
  `State_ID` INT ,
  PRIMARY KEY (`City_ID`)); # City_ID set as the primary key to uniquely identify each row

ALTER TABLE `Housing_DB`.`City` #Altered the city table schema
ADD FOREIGN KEY (State_ID) REFERENCES State(State_ID); #made the state_id column as a foreign key referring to state table's primary key.

# Created a table to store the Address

CREATE TABLE `Housing_DB`.`Address` (
  `Address_ID` INT NOT NULL AUTO_INCREMENT, ##set the constraint for Type_ID to be non null as this value should never be null but as further I have set this attribute as primary key it automatically considers it as not null.
  `Street` VARCHAR(150) ,
  `zipcode` VARCHAR(5) ,
  `city_id` INT ,
  PRIMARY KEY (`Address_ID`), # Address_ID set as the primary key to uniquely identify each row
  CONSTRAINT `city_id`
    FOREIGN KEY (`city_id`)
    REFERENCES `Housing_DB`.`City` (`City_ID`)); #made the city_id column as a foreign key referring to city table's primary key) 
  
 # Created a table to store the Housing Details
 
CREATE TABLE `Housing_DB`.`HousingDetails` (
  `housing_id` INT NOT NULL AUTO_INCREMENT, ##set the constraint for Type_ID to be non null as this value should never be null but as further I have set this attribute as primary key it automatically considers it as not null.
  `beds` INT ,
  `baths` INT ,
  `square_feet` INT ,
  `sales_date` DATETIME ,
  `price` INT ,
  `map_id` INT ,
  `type_id` INT ,
  `address_id` INT ,
  PRIMARY KEY (`housing_id`), # housing_id set as the primary key to uniquely identify each row
  CONSTRAINT `type_id`
    FOREIGN KEY (`type_id`)
REFERENCES `Housing_DB`.`Type` (`Type_ID`), #made the Type_ID column as a foreign key referring to state table's primary key.
  CONSTRAINT `map_id`
    FOREIGN KEY (`map_id`)
    REFERENCES `Housing_DB`.`MapAttributes` (`Map_ID`), #made the Map_ID column as a foreign key referring to state table's primary key.
  CONSTRAINT `address_id`
    FOREIGN KEY (`address_id`)
    REFERENCES `Housing_DB`.`Address` (`Address_ID`)); #made the Address_ID column as a foreign key referring to state table's primary key.
   
#Created a main table to import the dataset   
   CREATE TABLE `Housing_DB`.`sacremento` (
  `street` varchar(150),
  `city` varchar(45) ,
  `zip` varchar(5) ,
  `state` varchar(45) ,
  `beds` INT,
  `baths` INT,
  `sq_ft` INT,
  `type` varchar(45) ,
  `sales_date` varchar(45) ,
  `price` INT,
  `Latitude` DECIMAL(10,8) ,
  `Longitude` DECIMAL(11,8)
) ;

#Created a new table to store the modified and formatted data from the main table created above
CREATE TABLE `Housing_DB`.`sacremento_new` (
  `street` varchar(150) ,
  `city` varchar(45) ,
  `zip` varchar(5) ,
  `state` varchar(45) ,
  `beds` INT,
  `baths` INT,
  `sq_ft` INT,
  `type` varchar(45) ,
  `Sales_date` DATETIME,
  `price` INT,
  `Latitude` DECIMAL(10,8) ,
  `Longitude` DECIMAL(11,8)
) ;

# Inserted the data from main table to sacremento_new table
insert into `Housing_DB`.sacremento_new
SELECT street,
       city,
       zip,
       state,
       beds,
       baths,
       sq_ft,
       type,
       STR_TO_DATE(sales_date,'%a %M %d %T EDT %Y') Sales_date, #converted the date which was stored in string format in dataset to date datatype and parsed the date parts as per the requirement.
       price,
       latitude,
       longitude
FROM   `Housing_DB`.sacremento;   

#Inserted map locations details from new main table  
INSERT INTO `Housing_DB`.mapattributes
            (latitude,
             longitude)
SELECT latitude,
       longitude
FROM   `Housing_DB`.sacremento_new; 

 #Inserted house type details from new main table  
INSERT INTO `Housing_DB`.type
            (type)
SELECT DISTINCT type
FROM   `Housing_DB`.sacremento_new; 

 #Inserted state from new main table  
INSERT INTO `Housing_DB`.state
            (state)
SELECT DISTINCT state
FROM   `Housing_DB`.sacremento_new; 

 #Inserted state from new main table  
INSERT INTO `Housing_DB`.city
            (city_name,
             state_id)
SELECT DISTINCT city,
                state_id
FROM   `Housing_DB`.sacremento_new SN
       INNER JOIN `Housing_DB`.state S # as wanted to store the state_id as foreign key so added state table join with the main table
               ON SN.state = S.state; 

 #Inserted Address from new main table  
INSERT INTO `Housing_DB`.address
            (street,
             zipcode,
             city_id)
SELECT DISTINCT street,#to avoid duplicate rows to get inserted added distinct keyword
                zip,
                c.city_id
FROM   `Housing_DB`.sacremento_new SN
       INNER JOIN `Housing_DB`.city C
               ON SN.city = C.city_name; # as wanted to store the city_id as foreign key so added city table join with the main table

 #Inserted housing details from new main table  
INSERT INTO `Housing_DB`.housingdetails
            (beds,
             baths,
             square_feet,
             sales_date,
             price,
             map_id,
             type_id,
             address_id)
SELECT DISTINCT beds, #to avoid duplicate rows to get inserted added distinct keyword
                baths,
                sq_ft,
                sales_date,
                price,
                map_id,
                type_id,
                address_id
FROM   `Housing_DB`.sacremento_new SN
       INNER JOIN `Housing_DB`.city C
               ON C.city_name = Sn.city # as wanted to give join on address table to get the address_id, added city table join with the main table
       INNER JOIN `Housing_DB`.address A
               ON A.city_id = C.city_id 
                  AND A.zipcode = SN.zip # mapping the required columns with the main tables
                  AND A.street = Sn.street
       INNER JOIN `Housing_DB`.mapattributes M
               ON SN.latitude = M.latitude # mapping the required columns with the main tables
                  AND SN.longitude = M.longitude
       INNER JOIN `Housing_DB`.type T
               ON SN.type = T.type; 


#which city has on highest average cost of housing for residenial type?
SELECT city_name as City,
       Avg(price) AS 'Average Price' # calculated the average price
FROM   `Housing_DB`.housingdetails H
       INNER JOIN `Housing_DB`.type T
               ON T.type_id = H.type_id
       INNER JOIN `Housing_DB`.address A #Added joined on the table as per required in the business question
               ON A.address_id = H.address_id
       INNER JOIN `Housing_DB`.city C
               ON C.city_id = A.city_id
WHERE  T.type = 'Residential' #gave the underlying condition as per the business question
GROUP  BY city_name #grouped data on the basis of city
ORDER  BY 2 DESC; #sorted the data on the basis of price in descending order

# Which street in city SACRAMENTO has most expensive Multi-family housing?
SELECT street,
       Max(price)AS 'Maximum Price' # calculated the Maximum price
FROM   `Housing_DB`.address A
       INNER JOIN `Housing_DB`.housingdetails H
               ON A.address_id = H.address_id
       INNER JOIN `Housing_DB`.city C
               ON C.city_id = A.city_id #Added joined on the table as per required in the business question
       INNER JOIN `Housing_DB`.type T
               ON T.type_id = H.type_id
WHERE  T.type = 'Multi-Family'
       AND C.city_name = 'SACRAMENTO' #gave the underlying condition as per the business question
GROUP  BY street #grouped data on the basis of street
ORDER  BY 2 DESC; #sorted the data on the basis of price in descending order


#Highest number of houses sold on which day in Sacremento for Residential housing?
SELECT Dayname(sales_date) as 'Day', #extracted the week of the day from date
       Count(*) NoOfHousesSold # calculated number of houses sold
FROM   `Housing_DB`.housingdetails H
       INNER JOIN `Housing_DB`.address A
               ON H.address_id = A.address_id
       INNER JOIN `Housing_DB`.city C
               ON C.city_id = A.city_id #Added joined on the table as per required in the business question
       INNER JOIN `Housing_DB`.type T
               ON T.type_id = H.type_id
WHERE  T.type = 'Residential'
       AND c.city_name = 'SACRAMENTO' #gave the underlying condition as per the business question
GROUP  BY Dayname(sales_date)
ORDER  BY noofhousessold DESC;  #sorted the data on the basis of number of houses sold in descending order

#What is the average price of Condo housing with 2 bedroom and 1 bathroom in ROSEVILLE?
SELECT Avg(price) AS 'Average Price' # calculated the average price
FROM   `Housing_DB`.housingdetails H
       INNER JOIN `Housing_DB`.type T
               ON T.type_id = H.type_id
       INNER JOIN `Housing_DB`.address A
               ON A.address_id = H.address_id #Added joined on the table as per required in the business question
       INNER JOIN `Housing_DB`.city C
               ON C.city_id = A.city_id
WHERE  c.city_name = 'ROSEVILLE' #gave the underlying conditions as per the business question
       AND H.beds = 2
       AND H.baths = 1
       AND T.type = 'Condo'; 



