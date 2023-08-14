/*
 * The year 2022*/
USE cyclistic;

-- ANALYZE BASED ON QUARTERS IN 2022 
ANALYZE TABLE quarter_1;
ANALYZE TABLE quarter_2;
ANALYZE TABLE quarter_3;
ANALYZE TABLE quarter_4;

SELECT 
	TABLE_NAME AS quarter_name, 
	TABLE_ROWS AS total_trips
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
	
/*
 * SO MOST OF TRIPS FOCUS ON QUARTER 2 AND QUARTER 3*/

-- Caculate avg ride length
SELECT SEC_TO_TIME(AVG(
	TIME_TO_SEC(ride_length)) 
	) AS avg_ride_length 
FROM (
	SELECT ride_id, ride_length FROM quarter_1
	UNION
	SELECT ride_id, ride_length FROM quarter_2
	UNION
	SELECT ride_id, ride_length FROM quarter_3
	UNION
	SELECT ride_id, ride_length FROM quarter_4
) AS sumary;

-- avg_ride_length by member_casual
SELECT 
	member_casual,
	SEC_TO_TIME(AVG(TIME_TO_SEC(ride_length)) 
	) AS avg_ride_length 
FROM (
	SELECT ride_id, member_casual, ride_length FROM quarter_1
	UNION
	SELECT ride_id, member_casual, ride_length FROM quarter_2
	UNION
	SELECT ride_id, member_casual, ride_length FROM quarter_3
	UNION
	SELECT ride_id, member_casual, ride_length FROM quarter_4
) AS sumary
GROUP BY member_casual
ORDER BY member_casual;

-- avg_ride_length by rideable_type
SELECT 
	rideable_type,
	SEC_TO_TIME(AVG(TIME_TO_SEC(ride_length)) 
	) AS avg_ride_length 
FROM (
	SELECT ride_id, rideable_type, ride_length FROM quarter_1
	UNION
	SELECT ride_id, rideable_type, ride_length FROM quarter_2
	UNION
	SELECT ride_id, rideable_type, ride_length FROM quarter_3
	UNION
	SELECT ride_id, rideable_type, ride_length FROM quarter_4
) AS sumary
GROUP BY rideable_type
ORDER BY rideable_type;

-- GET FULL YEAR QUERY FOR VIS
SELECT *
FROM quarter_1;

SELECT *
FROM quarter_2;

SELECT *
FROM quarter_3;

SELECT *
FROM quarter_4;
