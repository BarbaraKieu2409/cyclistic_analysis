USE cyclistic;

-- Find the total trips, total member trips and total casual trips
SELECT 
	COUNT(ride_id) AS total_trips, 
	SUM(CASE WHEN member_casual = 'casual' THEN 1 ELSE 0 END) AS total_casual_trips,
	SUM(CASE WHEN member_casual = 'member' THEN 1 ELSE 0 END) AS total_member_trips,
	'quarter_3' AS quarter_name
FROM quarter_3;

/*
 * QUARTER 3*/
-- (MAX, MIN, TOTAL, MEAN - AVG)
SELECT 
	'quarter_3' AS quarter_name,
	member_casual,
	COUNT(*) AS total_rides,
	SEC_TO_TIME(
		AVG(TIME_TO_SEC(ride_length))
	) AS avg_ride_length,
	MIN(ride_length) AS min_ride_length,
	MAX(ride_length) AS max_ride_length
FROM quarter_3
GROUP BY member_casual
ORDER BY member_casual;

-- Q2 - MEDIAN
SELECT 
	'quarter_3' AS quarter_name,
	member_casual,
	SEC_TO_TIME(
		AVG(TIME_TO_SEC(ride_length))
	) AS median_ride_length
FROM (
	SELECT 
		member_casual,
		ride_length,
		ROW_NUMBER() OVER(PARTITION BY member_casual ORDER BY ride_length) AS row_num,
		COUNT(*) OVER(PARTITION BY member_casual) as total
	FROM quarter_3
	) AS quarter_3_sub
WHERE 
	row_num IN (FLOOR((total + 1)/2), FLOOR((total+2)/2))
GROUP BY member_casual
ORDER BY member_casual;

-- Q1
SELECT
	'quarter_3' AS quarter_name,
	member_casual,
	ride_length AS Q1_ride_length
FROM (
	SELECT 
		member_casual,
		ride_length,
		ROW_NUMBER() OVER(PARTITION BY member_casual ORDER BY ride_length) AS row_num,
		COUNT(*) OVER(PARTITION BY member_casual) as total
	FROM quarter_3
	) AS quarter_3_sub
WHERE 
	row_num = ROUND(0.25*total)
ORDER BY member_casual;

-- Q3
SELECT 
	'quarter_3' AS quarter_name,
	member_casual,
	ride_length AS Q3_ride_length
FROM (
	SELECT 
		member_casual,
		ride_length,
		ROW_NUMBER() OVER(PARTITION BY member_casual ORDER BY ride_length) AS row_num,
		COUNT(*) OVER(PARTITION BY member_casual) as total
	FROM quarter_3
	) AS quarter_3_sub
WHERE 
	row_num = ROUND(0.75*total)
ORDER BY member_casual;

-- MODE
SELECT 
	'quarter_3' AS quarter_name,
	member_casual, 
	ride_length AS mode_ride_length
FROM (
    SELECT member_casual, ride_length, COUNT(ride_length) AS ride_length_counted,
           ROW_NUMBER() OVER (PARTITION BY member_casual ORDER BY COUNT(ride_length) DESC) AS row_num
    FROM quarter_3
    GROUP BY member_casual, ride_length
) AS quarter_3_sub
WHERE row_num = 1;

/*
 * Based on the result in above, I will state that almose casual use bycycle between 6 and 30 minutes, 
 * and almost member use bycycle between 4 and 15 minutes in quarter 3*/
-- STATS START STATION MISING BY TYPE OF USER 
SELECT member_casual , COUNT(*) AS total_start_missing 
FROM quarter_3
WHERE LENGTH(start_station_id) = 0
GROUP BY member_casual
ORDER BY member_casual;

-- STATS END STATION MISSING BY TYPE OF USER
SELECT member_casual, COUNT(*) AS total_end_missing
FROM quarter_3
WHERE LENGTH(end_station_id) = 0
GROUP BY member_casual
ORDER BY member_casual;

-- FIND THE NUMBER OF USER USE BICYCLE MORE THAN 30 MINUTES
SELECT member_casual, COUNT(*) AS total_member_use_too_long
FROM quarter_3
WHERE 
	SEC_TO_TIME(ride_length) > 30*60 
GROUP BY member_casual
ORDER BY member_casual;

-- STATS START GEO DATA MISSING BY TYPE OF USER 
SELECT member_casual, COUNT(*) AS total_start_geo_missing 
FROM quarter_3
WHERE 
	start_lat = 0 AND start_lng = 0
GROUP BY member_casual
ORDER BY member_casual;

-- STATS END GEO DATA MISSING BY TYPE OF USER 
SELECT member_casual, COUNT(*) AS total_start_geo_missing 
FROM quarter_3
WHERE 
	(end_lat = 0 AND end_lng = 0)
	OR
	(end_lat = NULL)
GROUP BY member_casual
ORDER BY member_casual;

-- Export to csv for vis
SELECT *
FROM quarter_3