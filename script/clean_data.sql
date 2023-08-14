 /*
  * Explore data
  * */
USE cyclistic;;

-- GET ALL TABLE_NAME IN THIS DATABASE 
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'cyclistic';

-- REANALYZE FOR EACH TABLE
ANALYZE TABLE 202201_divvy_tripdata;
ANALYZE TABLE 202202_divvy_tripdata;
ANALYZE TABLE 202203_divvy_tripdata;
ANALYZE TABLE 202204_divvy_tripdata;
ANALYZE TABLE 202205_divvy_tripdata;
ANALYZE TABLE 202206_divvy_tripdata;
ANALYZE TABLE 202207_divvy_tripdata;
ANALYZE TABLE 202208_divvy_tripdata;
ANALYZE TABLE 202209_divvy_publictripdata;
ANALYZE TABLE 202210_divvy_tripdata;
ANALYZE TABLE 202211_divvy_tripdata;
ANALYZE TABLE 202212_divvy_tripdata;

-- GET TABLE NAME AND TOTAL ROW
SELECT TABLE_NAME, TABLE_ROWS AS TOTAL_ROW
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'cyclistic';

-- GET COLUMN NAME
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'202201_divvy_tripdata';

-- GET 5 FIRST ROWS IN ANY TABLE (SAME SCHMEA)
SELECT *
FROM 202201_divvy_tripdata
LIMIT 5;

-- DATA AGGREATOR BY QUARTER YEAR
CREATE TABLE quarter_1
SELECT DISTINCT * FROM 202201_divvy_tripdata
UNION
SELECT DISTINCT * FROM 202202_divvy_tripdata
UNION
SELECT DISTINCT * FROM 202203_divvy_tripdata;

CREATE TABLE quarter_2
SELECT DISTINCT * FROM 202204_divvy_tripdata
UNION 
SELECT DISTINCT * FROM 202205_divvy_tripdata
UNION 
SELECT DISTINCT * FROM 202206_divvy_tripdata;

CREATE TABLE quarter_3
SELECT DISTINCT * FROM 202207_divvy_tripdata 
UNION 
SELECT DISTINCT * FROM 202208_divvy_tripdata
UNION 
SELECT DISTINCT * FROM 202209_divvy_publictripdata;

CREATE TABLE quarter_4
SELECT DISTINCT * FROM 202210_divvy_tripdata
UNION 
SELECT DISTINCT * FROM 202211_divvy_tripdata
UNION 
SELECT DISTINCT * FROM 202212_divvy_tripdata;

-- GET INFO OF 4 QUARTER TABLES
ANALYZE TABLE quarter_1;
ANALYZE TABLE quarter_2;
ANALYZE TABLE quarter_3;
ANALYZE TABLE quarter_4;

SELECT TABLE_NAME, TABLE_ROWS AS TOTAL_ROW
FROM INFORMATION_SCHEMA.TABLES
WHERE 
	TABLE_SCHEMA = 'cyclistic'
	AND
	TABLE_NAME = 'quarter_1'
	OR 
	TABLE_NAME = 'quarter_2'
	OR
	TABLE_NAME = 'quarter_3'
	OR
	TABLE_NAME = 'quarter_4';
	
-- GET 5 FIRST ROWS IN QUARTER 1
SELECT *
FROM quarter_1 
LIMIT 5;

-- DOES STARTED AT OUT OF RANGE?
SELECT *
FROM quarter_1 
WHERE
	NOT(
		MONTH(started_at) >= 1 
		AND 
		MONTH(started_at) <= 3
		AND
		YEAR(started_at) = 2022
	);
	
-- SIMILAR TO QUARTER 2
SELECT *
FROM quarter_2
WHERE
	NOT(
		MONTH(started_at) >= 4
		AND 
		MONTH(started_at) <= 6
		AND
		YEAR(started_at) = 2022
	);
	
-- SIMILAR TO QUARTER 3
SELECT *
FROM quarter_3
WHERE
	NOT(
		MONTH(started_at) >= 7
		AND 
		MONTH(started_at) <= 9
		AND
		YEAR(started_at) = 2022
	);
	
	
-- SIMILAR TO QUARTER 4
SELECT *
FROM quarter_4
WHERE
	NOT(
		MONTH(started_at) >= 10
		AND 
		MONTH(started_at) <= 12
		AND
		YEAR(started_at) = 2022
	);
	
	
-- FIND INCONSISTENCE TIME
SELECT COUNT(*) AS inconsistent_date
FROM quarter_1
WHERE
	ended_at <= started_at;
	
SELECT COUNT(*) AS inconsistent_date
FROM quarter_2
WHERE 
	ended_at <= started_at;
	
SELECT COUNT(*) AS inconsistent_date
FROM quarter_3
WHERE 
	ended_at <= started_at;
	
SELECT COUNT(*) AS inconsistent_date
FROM quarter_4
WHERE 
	ended_at <= started_at;
	
-- DELETE IMCONSISTENCE DATE ROWS (if started_at <= ended_at)
DELETE FROM quarter_1
WHERE started_at >= ended_at;

DELETE FROM quarter_2
WHERE started_at >= ended_at;

DELETE FROM quarter_3
WHERE started_at >= ended_at;

DELETE FROM quarter_4
WHERE started_at >= ended_at;


-- FIND NULL VALUE IN start_lat/start_lng/end_lat/end_lng
SELECT * 
FROM quarter_1  
WHERE 
	start_lat = NULL 
	OR 
	start_lat = 0
	OR 
	start_lng = NULL
	OR 
	start_lng = 0
	OR 
	end_lat = NULL
	OR 
	end_lat = 0
	OR 
	end_lng = NULL
	OR
	end_lng = 0;
SELECT * 
FROM quarter_2 
WHERE  
	start_lat = NULL 
	OR 
	start_lat = 0
	OR 
	start_lng = NULL
	OR 
	start_lng = 0
	OR 
	end_lat = NULL
	OR 
	end_lat = 0
	OR 
	end_lng = NULL
	OR
	end_lng = 0;

SELECT * 
FROM quarter_3
WHERE  
	start_lat = NULL 
	OR 
	start_lat = 0
	OR 
	start_lng = NULL
	OR 
	start_lng = 0
	OR 
	end_lat = NULL
	OR 
	end_lat = 0
	OR 
	end_lng = NULL
	OR
	end_lng = 0;

SELECT * 
FROM quarter_4
WHERE  
	start_lat = NULL 
	OR 
	start_lat = 0
	OR 
	start_lng = NULL
	OR 
	start_lng = 0
	OR 
	end_lat = NULL
	OR 
	end_lat = 0
	OR 
	end_lng = NULL
	OR
	end_lng = 0;

-- FIND MISSING AT start_station_id
 SELECT COUNT(*) AS start_station_id_missing
 FROM quarter_1 
 WHERE 
	LENGTH(start_station_id) = 0;

 SELECT * 
 FROM quarter_1 
 WHERE 
	LENGTH(start_station_id) = 0;

/* FILL start_station_id missing by the another rows which
 * same start_lat and start_lng if its start_station_id not
 * missing 
*/

-- FIRST WE FIND THAT DOES THE VALUES FOR FILLING EXISTS
SELECT t1.start_station_id, t2.start_station_id, t1.start_lat 
FROM
	quarter_1 AS t1
	JOIN quarter_1 AS t2
	ON t1.ride_id = t2.ride_id
WHERE 
	LENGTH(t1.start_station_id) = 0
	AND
		(
		t1.start_lat = t2.start_lat
		OR 
		t1.start_station_id = t2.end_station_id 
		)
	AND
		(
		t1.start_lng = t2.start_lng
		OR 
		t1.start_station_id = t2.end_station_id 
		)
	AND 
	LENGTH(t2.start_station_id) != 0;

-- FIND THE VALUE TO FILL BY end_station_id 
SELECT t1.*
FROM
	quarter_1 AS t1
	JOIN
	quarter_1 AS t2
	ON t1.ride_id = t2.ride_id 
WHERE 
	LENGTH(t1.start_station_id) = 0
	AND 
	t1.end_station_id = t2.end_station_id
	AND
	LENGTH(t1.end_station_id) != 0
	AND 
	LENGTH(t2.start_station_id) != 0

-- BECAUSE THERE ARE NOT ANY VALUE TO FILL MISSING BY GEO DATA OR THE SAME END STATION ID,
-- I WILL NOT FILL IT
	
-- TRANSFORM day_of_week to day name 
-- CHANGE day_of_week to VARCHAR(50)
ALTER TABLE quarter_1 
MODIFY COLUMN day_of_week VARCHAR(50);

ALTER TABLE quarter_2
MODIFY COLUMN day_of_week VARCHAR(50);

ALTER TABLE quarter_3
MODIFY COLUMN day_of_week VARCHAR(50);

ALTER TABLE quarter_4 
MODIFY COLUMN day_of_week VARCHAR(50);

-- TRANSFORM
UPDATE quarter_1 
SET 
	day_of_week =
		CASE
			WHEN day_of_week = '1' THEN 'Sunday'
			WHEN day_of_week = '2' THEN 'Monday'
			WHEN day_of_week = '3' THEN 'Tuesday'
			WHEN day_of_week = '4' THEN 'Wednesday'
			WHEN day_of_week = '5' THEN 'Thursday'
			WHEN day_of_week = '6' THEN 'Friday'
			WHEN day_of_week = '7' THEN 'Saturday'
		END
WHERE 
	 day_of_week IN ('1', '2', '3', '4', '5', '6', '7');
	
UPDATE quarter_2
SET 
	day_of_week =
		CASE
			WHEN day_of_week = '1' THEN 'Sunday'
			WHEN day_of_week = '2' THEN 'Monday'
			WHEN day_of_week = '3' THEN 'Tuesday'
			WHEN day_of_week = '4' THEN 'Wednesday'
			WHEN day_of_week = '5' THEN 'Thursday'
			WHEN day_of_week = '6' THEN 'Friday'
			WHEN day_of_week = '7' THEN 'Saturday'
		END
WHERE 
	 day_of_week IN ('1', '2', '3', '4', '5', '6', '7');

UPDATE quarter_3
SET 
	day_of_week =
		CASE
			WHEN day_of_week = '1' THEN 'Sunday'
			WHEN day_of_week = '2' THEN 'Monday'
			WHEN day_of_week = '3' THEN 'Tuesday'
			WHEN day_of_week = '4' THEN 'Wednesday'
			WHEN day_of_week = '5' THEN 'Thursday'
			WHEN day_of_week = '6' THEN 'Friday'
			WHEN day_of_week = '7' THEN 'Saturday'
		END
WHERE 
	 day_of_week IN ('1', '2', '3', '4', '5', '6', '7');	

UPDATE quarter_4
SET 
	day_of_week =
		CASE
			WHEN day_of_week = '1' THEN 'Sunday'
			WHEN day_of_week = '2' THEN 'Monday'
			WHEN day_of_week = '3' THEN 'Tuesday'
			WHEN day_of_week = '4' THEN 'Wednesday'
			WHEN day_of_week = '5' THEN 'Thursday'
			WHEN day_of_week = '6' THEN 'Friday'
			WHEN day_of_week = '7' THEN 'Saturday'
		END
WHERE 
	 day_of_week IN ('1', '2', '3', '4', '5', '6', '7');
	
-- 
		