/*
 * QUARTER 3*/
USE cyclistic;

-- Find the total trips, total member trips and total casual trips
SELECT 
	COUNT(ride_id) AS total_trips, 
	SUM(CASE WHEN member_casual = 'casual' THEN 1 ELSE 0 END) AS total_casual_trips,
	SUM(CASE WHEN member_casual = 'member' THEN 1 ELSE 0 END) AS total_member_trips,
	'quarter_3' AS quarter_name
FROM quarter_3;

-- (MAX, MIN, TOTAL, MEAN - AVG)
SELECT 
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
SELECT member_casual, ride_length AS mode_ride_length
FROM (
    SELECT member_casual, ride_length, COUNT(ride_length) AS ride_length_counted,
           ROW_NUMBER() OVER (PARTITION BY member_casual ORDER BY COUNT(ride_length) DESC) AS row_num
    FROM quarter_3
    GROUP BY member_casual, ride_length
) AS quarter_3_sub
WHERE row_num = 1
ORDER BY member_casual;

/*
 * Based on the result in above, I will state that almose casual use bycycle between 7 and 24 minutes, 
 * and almost member use bycycle between 5 and 16 minutes in quarter 3*/

-- Stats the ride_length by rideable_type
SELECT 
	member_casual, 
	rideable_type, 
	COUNT(*) AS total_trip,
	MAX(ride_length) AS max_ride_length,
	MIN(ride_length) AS min_ride_length,
	SEC_TO_TIME(
		AVG(TIME_TO_SEC(ride_length))
	) AS avg_ride_length	
FROM quarter_3
GROUP BY member_casual, rideable_type 
ORDER BY member_casual;


-- Stats casual which ride_length > 24 minutes and < 7 minutes | 7 <= ride_length <= 24 minutes by rideable_type
SELECT 
	'quarter_3' AS quarter_name,
	member_casual,
	rideable_type,
	'use more than 24m' AS ride_length,
	COUNT(*) AS total
FROM quarter_3
WHERE 
	TIME_TO_SEC(ride_length) > 24*60
	AND
	member_casual = 'casual'
GROUP BY rideable_type
UNION 
SELECT 
	'quarter_3' AS quarter_name,
	member_casual,
	rideable_type,
	'use less than 7m' AS ride_length,
	COUNT(*) AS total
FROM quarter_3
WHERE 
	TIME_TO_SEC(ride_length) < 7 * 60
	AND
	member_casual = 'casual'
GROUP BY rideable_type
UNION 
SELECT
	'quarter_3' AS quarter_name,
	member_casual,
	rideable_type,
	'use between 7 and 24m' AS ride_length,
	COUNT(*) AS total
FROM quarter_3
WHERE 
	TIME_TO_SEC(ride_length) >= 7 * 60
	AND
	TIME_TO_SEC(ride_length) <= 24 * 60 
	AND
	member_casual = 'casual'
GROUP BY rideable_type 
ORDER BY rideable_type, ride_length;

-- Similar for member
SELECT 
	'quarter_3' AS quarter_name,
	member_casual,
	rideable_type,
	'use more than 16m' AS ride_length,
	COUNT(*) AS total
FROM quarter_3
WHERE 
	TIME_TO_SEC(ride_length) > 16*60
	AND
	member_casual = 'member'
GROUP BY rideable_type
UNION 
SELECT 
	'quarter_3' AS quarter_name,
	member_casual,
	rideable_type,
	'use less than 5m' AS ride_length,
	COUNT(*) AS total
FROM quarter_3
WHERE 
	TIME_TO_SEC(ride_length) < 5 * 60
	AND
	member_casual = 'member'
GROUP BY rideable_type
UNION 
SELECT
	'quarter_3' AS quarter_name,
	member_casual,
	rideable_type,
	'use between 5 and 16m' AS ride_length,
	COUNT(*) AS total
FROM quarter_3
WHERE 
	TIME_TO_SEC(ride_length) >= 5 * 60
	AND
	TIME_TO_SEC(ride_length) <= 16 * 60 
	AND
	member_casual = 'member'
GROUP BY rideable_type 
ORDER BY rideable_type, ride_length;

-- Based on start_station_id
-- At which station member or casual usually start?
SELECT 
	member_casual, 
	'max' AS proper,
	start_station_id,
	start_station_name,
	start_station_counted 
FROM (
	SELECT 
		member_casual,
		start_station_id,
		start_station_name,
		COUNT(start_station_id) AS start_station_counted,
		ROW_NUMBER() OVER (PARTITION BY member_casual ORDER BY COUNT(start_station_id) DESC) AS row_num,
		COUNT(*) OVER (PARTITION BY member_casual) AS row_total
	FROM quarter_3
	WHERE
		LENGTH(start_station_id) != 0
	GROUP BY member_casual, start_station_id, start_station_name
	) AS temp
WHERE row_num = 1
UNION
SELECT 
	member_casual, 
	'min' AS proper,
	start_station_id,
	start_station_name,
	start_station_counted 
FROM (
	SELECT 
		member_casual,
		start_station_id,
		start_station_name,
		COUNT(start_station_id) AS start_station_counted,
		ROW_NUMBER() OVER (PARTITION BY member_casual ORDER BY COUNT(start_station_id) ASC) AS row_num,
		COUNT(*) OVER (PARTITION BY member_casual) AS row_total
	FROM quarter_3
	WHERE
		LENGTH(start_station_id) != 0
	GROUP BY member_casual, start_station_id, start_station_name
	) AS temp
WHERE row_num = 1
UNION 
SELECT 
	member_casual, 
	'avg' AS proper,
	start_station_id,
	start_station_name,
	start_station_counted
FROM (
	SELECT 
		member_casual,
		start_station_id,
		start_station_name,
		COUNT(start_station_id) AS start_station_counted,
		ROW_NUMBER() OVER (PARTITION BY member_casual ORDER BY COUNT(start_station_id) DESC) AS row_num,
		COUNT(*) OVER (PARTITION BY member_casual) AS row_total
	FROM quarter_3
	WHERE
		LENGTH(start_station_id) != 0
	GROUP BY member_casual, start_station_id, start_station_name
	) AS temp
WHERE row_num = ROUND(row_total/2) 
ORDER BY member_casual;

-- Based on end_station_id
-- At which station member or casual usually end?
SELECT 
	member_casual, 
	'max' AS proper,
	end_station_id,
	end_station_name,
	end_station_counted 
FROM (
	SELECT 
		member_casual,
		end_station_id,
		end_station_name,
		COUNT(start_station_id) AS end_station_counted,
		ROW_NUMBER() OVER (PARTITION BY member_casual ORDER BY COUNT(end_station_id) DESC) AS row_num,
		COUNT(*) OVER (PARTITION BY member_casual) AS row_total
	FROM quarter_3
	WHERE
		LENGTH(end_station_id) != 0
	GROUP BY member_casual, end_station_id, end_station_name
	) AS temp
WHERE row_num = 1
UNION
SELECT 
	member_casual, 
	'min' AS proper,
	end_station_id,
	end_station_name,
	end_station_counted 
FROM (
	SELECT 
		member_casual,
		end_station_id,
		end_station_name,
		COUNT(end_station_id) AS end_station_counted,
		ROW_NUMBER() OVER (PARTITION BY member_casual ORDER BY COUNT(end_station_id) ASC) AS row_num,
		COUNT(*) OVER (PARTITION BY member_casual) AS row_total
	FROM quarter_3
	WHERE
		LENGTH(end_station_id) != 0
	GROUP BY member_casual, end_station_id, end_station_name
	) AS temp
WHERE row_num = 1
UNION 
SELECT 
	member_casual, 
	'med' AS proper,
	end_station_id,
	end_station_name,
	end_station_counted 
FROM (
	SELECT 
		member_casual,
		end_station_id,
		end_station_name,
		COUNT(start_station_id) AS end_station_counted,
		ROW_NUMBER() OVER (PARTITION BY member_casual ORDER BY COUNT(end_station_id) DESC) AS row_num,
		COUNT(*) OVER (PARTITION BY member_casual) AS row_total
	FROM quarter_3
	WHERE
		LENGTH(end_station_id) != 0
	GROUP BY member_casual, end_station_id, end_station_name
	) AS temp
WHERE row_num = ROUND(row_total/2) 
ORDER BY member_casual;

-- define missing
-- STATS START STATION MISING BY TYPE OF USER 
SELECT member_casual, rideable_type, COUNT(*) AS total_start_missing 
FROM quarter_3
WHERE LENGTH(start_station_id) = 0
GROUP BY member_casual, rideable_type
ORDER BY member_casual;

-- STATS END STATION MISSING BY TYPE OF USER
SELECT member_casual, rideable_type, COUNT(*) AS total_end_missing
FROM quarter_3
WHERE LENGTH(end_station_id) = 0
GROUP BY member_casual, rideable_type
ORDER BY member_casual;

-- Stats start station missing and end station missing
SELECT member_casual, rideable_type, COUNT(*) AS total_missing
FROM quarter_3
WHERE LENGTH(end_station_id) = 0 AND LENGTH(start_station_id) = 0
GROUP BY member_casual, rideable_type
ORDER BY member_casual;

-- Stats start station missing and end station not missing and otherwise
SELECT member_casual, rideable_type, COUNT(*) AS total_missing
FROM quarter_3
WHERE LENGTH(end_station_id) != 0 AND LENGTH(start_station_id) = 0
GROUP BY member_casual, rideable_type
ORDER BY member_casual;

SELECT member_casual, rideable_type, COUNT(*) AS total_missing
FROM quarter_3
WHERE LENGTH(end_station_id) = 0 AND LENGTH(start_station_id) != 0
GROUP BY member_casual, rideable_type
ORDER BY member_casual;

-- Based on GEO data
-- STATS START GEO DATA MISSING BY TYPE OF USER 
SELECT member_casual, COUNT(*) AS total_start_geo_missing 
FROM quarter_3
WHERE 
	(start_lat = 0 OR start_lng = 0)
	OR 
	(start_lat = NULL OR start_lng = NULL)
GROUP BY member_casual;

-- STATS END GEO DATA MISSING BY TYPE OF USER 
SELECT member_casual, COUNT(*) AS total_start_geo_missing 
FROM quarter_3
WHERE 
	(end_lat = 0 OR end_lng = 0)
	OR
	(end_lat = NULL OR end_lng = NULL)
GROUP BY member_casual;

-- TOP 10 geo start (not start from start_station)
SELECT 
	start_lat,
	start_lng,
	geo_counted
FROM (
	SELECT 
		start_lat, 
		start_lng,   
		COUNT(*) AS geo_counted,
		ROW_NUMBER() OVER (PARTITION BY start_lat, start_lng ORDER BY COUNT(*) DESC) AS row_num,
		COUNT(*) OVER (PARTITION BY start_lat, start_lng) AS row_total
	FROM quarter_3
	WHERE LENGTH(start_station_id) = 0
	GROUP BY start_lat, start_lng
	) AS temp
ORDER BY geo_counted
LIMIT 10;

-- Similar for geo end
SELECT 
	end_lat,
	end_lng,
	geo_counted
FROM (
	SELECT 
		end_lat, 
		end_lng,   
		COUNT(*) AS geo_counted,
		ROW_NUMBER() OVER (PARTITION BY end_lat, end_lng ORDER BY COUNT(*) DESC) AS row_num,
		COUNT(*) OVER (PARTITION BY end_lat, end_lng) AS row_total
	FROM quarter_3
	WHERE LENGTH(end_station_id) = 0
	GROUP BY end_lat, end_lng
	) AS temp
ORDER BY geo_counted
LIMIT 10;

-- based on day_of_week
-- Stats the number of trip in each type of user via day_of_week
SELECT 
	day_of_week, 
	member_casual,
	rideable_type,
	COUNT(*) AS total_trip
FROM quarter_3
GROUP BY 
	day_of_week, 
	member_casual,
	rideable_type 
ORDER BY day_of_week, member_casual, rideable_type;

SELECT 
	day_of_week,
	member_casual,
	rideable_type,
	MAX(ride_length) AS max_ride_length,
	MIN(ride_length) AS min_ride_length,
	SEC_TO_TIME(AVG(TIME_TO_SEC(ride_length))) AS avg_ride_length 
FROM quarter_3
GROUP BY 
	day_of_week,
	member_casual,
	rideable_type 
ORDER BY day_of_week, member_casual, rideable_type;

-- based on started_at and ended_at
SELECT 
	HOUR(started_at) AS hour_started_at,
	rideable_type,
	member_casual,
	COUNT(*) AS total_trip
FROM quarter_3
GROUP BY 
	HOUR(started_at),
	rideable_type,
	member_casual
ORDER BY total_trip DESC, member_casual;

SELECT 
	HOUR(ended_at) AS hour_ended_at,
	rideable_type,
	member_casual,
	COUNT(*) AS total_trip
FROM quarter_3
GROUP BY 
	HOUR(ended_at),
	rideable_type,
	member_casual
ORDER BY total_trip DESC, member_casual;

-- Caculate the ride length average by each ridable type
SELECT 
	rideable_type,
	SEC_TO_TIME(
		AVG(TIME_TO_SEC(ride_length))
	) AS avg_ride_length
FROM quarter_3
GROUP BY rideable_type
ORDER BY rideable_type;

-- Export to csv for vis
SELECT *
FROM quarter_3