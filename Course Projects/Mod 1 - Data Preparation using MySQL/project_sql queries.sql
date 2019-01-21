SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

#--------------------------------------
#Building table
#--------------------------------------

#-----------------------------------------------------
# Schema airbnb
#-----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `airbnb` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `airbnb`;


-- -----------------------------------------------------
-- Table structure for table `neighborhood`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS neighborhood (
  neighborhood_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  neighborhood VARCHAR(45) NOT NULL,
  borough VARCHAR(45) NOT NULL,
  PRIMARY KEY (neighborhood_id))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table structure for table `room_type`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS room_type (
  room_type_id SMALLINT UNSIGNED NOT NULL,
  room_type VARCHAR(45) NOT NULL,
  PRIMARY KEY (room_type_id))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table structure for table `room`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS room (
  room_id INT UNSIGNED NOT NULL,
  host_id INT UNSIGNED NOT NULL,
  latitude DECIMAL(10,8) NULL DEFAULT NULL,
  longitude DECIMAL(10,8) NULL DEFAULT NULL,
  room_type_id SMALLINT UNSIGNED NOT NULL,
  neighborhood_id SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY (room_id),
  CONSTRAINT fk_room_room_type
  FOREIGN KEY (room_type_id) REFERENCES room_type(room_type_id),
  CONSTRAINT fk_room_neighborhood
  FOREIGN KEY (neighborhood_id) REFERENCES neighborhood(neighborhood_id))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table structure for table `bedroom`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS bedroom (
  bedroom_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  bedrooms SMALLINT UNSIGNED NULL DEFAULT NULL,
  accommodates SMALLINT UNSIGNED NULL DEFAULT NULL,
  minstay INT UNSIGNED NULL DEFAULT NULL,
  price FLOAT UNSIGNED NULL DEFAULT NULL,
  room_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (bedroom_id),
    CONSTRAINT fk_bedroom_room
    FOREIGN KEY (room_id)
    REFERENCES room(room_id))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table structure for table `review`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS review (
  review_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  reviews SMALLINT NULL DEFAULT NULL,
  overall_satisfaction FLOAT NULL DEFAULT NULL,
  room_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (review_id),
  CONSTRAINT fk_review_room
    FOREIGN KEY (room_id)
    REFERENCES room(room_id))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;




#--------------------------------------
#Uploading data into table
#--------------------------------------

SHOW VARIABLES LIKE "secure_file_priv";

#Loading the values in 'neighborhood' table
load data infile 
'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\airbnb_srilanka\\neighborhood.csv'
into table neighborhood
fields terminated by ','
lines terminated by '\n'
ignore 1 rows;


#Loading the values in 'room_type' table
load data infile 
'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\airbnb_srilanka\\room_type.csv'
into table room_type
fields terminated by ','
lines terminated by '\n'
ignore 1 rows;


#Loading the values in 'room' table
load data infile 
'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\airbnb_srilanka\\room.csv'
into table room
fields terminated by ','
lines terminated by '\n'
ignore 1 rows;


#Loading the values in 'bedroom' table
load data infile 
'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\airbnb_srilanka\\bedroom.csv'
into table bedroom
fields terminated by ','
lines terminated by '\n'
ignore 1 rows;


#Loading the values in 'review' table
load data infile 
'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\airbnb_srilanka\\review.csv'
into table review
fields terminated by ','
lines terminated by '\n'
ignore 1 rows;




#--------------------------------------
#SQL Queries
#--------------------------------------

#Top 10 neighborhoods which have the maximum properties 
SELECT 
    n.neighborhood,
    n.borough,
    COUNT(r.room_id) AS total_properties
FROM
    neighborhood n
        INNER JOIN
    room r ON n.neighborhood_id = r.neighborhood_id
GROUP BY n.neighborhood
ORDER BY total_properties DESC
LIMIT 10;


#Property types having overall customer satisfaction 3.5 and above 
SELECT 
    rt.room_type as property_type, COUNT(r.room_type_id) as no_of_properties
FROM
    room r
        INNER JOIN
    room_type rt USING (room_type_id)
WHERE
    room_type_id != 4
        AND room_id IN (SELECT 
            room_id
        FROM
            review
        WHERE
            overall_satisfaction >= 3.5)
GROUP BY rt.room_type;


#Top neighborhoods which have the best customer satisfaction score
SELECT 
    n.neighborhood, n.borough, count(room_id) as top_rated
FROM
    neighborhood n
        INNER JOIN
    room r USING (neighborhood_id)
WHERE
	r.room_id IN (SELECT 
            room_id
        FROM
            review
        WHERE
            overall_satisfaction >= 3.5)
GROUP BY n.neighborhood
order by top_rated desc;


#Maximum, minimum and average price across all neighborhoods for 'Entire home/apt'
SELECT 
    n.neighborhood,
    n.borough,
    MAX(b.price) AS maximum_price,
    MIN(b.price) AS mininum_price,
    FLOOR(AVG(b.price)) AS average_price,
    COUNT(r.room_id) AS total_properties
FROM
    bedroom b
        INNER JOIN
    room r USING (room_id)
        INNER JOIN
    neighborhood n USING (neighborhood_id)
WHERE r.room_type_id = 1
GROUP BY n.neighborhood
ORDER BY total_properties DESC;