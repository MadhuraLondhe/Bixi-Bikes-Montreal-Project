#########################################
###### Bixi Bikes Montreal Project ######
#########################################

/*
Author: Madhura Londhe
Email: madhura.vlondhe@gmail.com
LinkedIn: linkedin.com/in/madhura-londhe
*/

USE bixi;

-- Let's first see how the tables look like.--

SELECT * FROM Trips
LIMIT 5;
/* We have the columns: id, start_date, start_station_code, end_date, end_station_code, duration_sec, is_member 
	The column names are straightforward. Each bike rental is called a trip. We have an ID for each trip, the start and end date of the trip, 
    start and end station codes, the duration of the trips and the membership status. 
    Okay, let's see what the other table has in it. */

SELECT * FROM stations
LIMIT 5;
/* We have the columns: code, name, latitude, longitude 
	So we have all the information about the bike rental stations: the station codes, station names, and the geographical location (latitude and longitude)
    Great! We can proceed to explore the dataset now. */

-- How many total trips are there? --
SELECT COUNT(*)
FROM trips;
-- Awesome! There are a total of 8,584,166 trips. Phew, it took 117 seconds to run the query. --

-- Let's see if there are trips taken for more than a day. --
SELECT COUNT(*)
FROM trips
WHERE duration_sec > 86400;
-- There are 86,400 seconds in a day. The result is 0. What if a trip ends after midnight? --

SELECT COUNT(id)
FROM trips
WHERE DAYOFWEEK(end_date) != DAYOFWEEK(start_date);
-- There are 43,045 trips. That's 0.50% of the total dataset. We can safely ignore the trips which end on the next day. --

----- Assumption: All the trips started in the year are considered here. A trip is defined based on a start date irrespective of the end date, end month or end year. -----

-- Let's see the period of the data --
SELECT MIN(start_date), MAX(start_date)
FROM trips;
-- So we have the first date as 2016-04-15 00:00:00 and the last date as 2017-11-15 23:59:00. --
-- Let's check how many stations are there --
SELECT DISTINCT(COUNT(*))
FROM stations;
-- There are total 540 distinct stations in the database. --

-- Alright, let's explore the database now. --

-- Total number of trips for year 2016 --
SELECT COUNT(1)
FROM trips
WHERE YEAR(start_date) = 2016;
-- Total no of trips in year 2016 = 3,917,401

-- Total number of trips for year 2017 --
SELECT COUNT(1)
FROM trips
WHERE YEAR(start_date) = 2017;
-- Total no of trips in year 2017= 4,666,765

-- Total number of trips for year 2016 broken-down by month --
SELECT MONTHNAME(start_date) as 'Month', year(start_date) as 'Year', COUNT(1) as total_trips
FROM trips
WHERE YEAR(start_date) = 2016
GROUP BY MONTHNAME(start_date)
ORDER BY MONTHNAME(start_date);
/* RESULT:
   +------------------------------+
   |   Month      |   total_trips |
   +------------------------------+
   |   April      |      189923   |
   +------------------------------+
   |   May        |      561077   |
   +------------------------------+
   |   June       |      631503   |
   +------------------------------+
   |   July       |      699248   |
   +------------------------------+
   |   August     |      672778   |
   +------------------------------+
   |   September  |      620263   |
   +------------------------------+
   |   October    |      392480   |
   +------------------------------+
   |   November   |      150129   |
   +------------------------------+
It looks like the majority of the rides are from May to September. There are no rides from December to March for obvious reasons.*/


-- Total no of trips for year 2017 broken-down by month --
SELECT MONTHNAME(start_date) as 'Month', COUNT(1) as num_of_trips
FROM trips
WHERE YEAR(start_date) = 2017
GROUP BY MONTHNAME(start_date), Month(start_date)
ORDER BY Month(start_date);
/* RESULT:
   +---------------------------------+
   |    Month      |   num_of_trips  |
   +---------------------------------+
   |    April      |      195662     |
   +---------------------------------+
   |    May        |      587447     |
   +---------------------------------+
   |    June       |      741835     |
   +---------------------------------+
   |    July       |      860732     |
   +---------------------------------+
   |    August     |      839938     |
   +---------------------------------+
   |    September  |      731851     |
   +---------------------------------+
   |    October    |      559506     |
   +---------------------------------+
   |    November   |      149794     |
   +---------------------------------+
We can find a similar trend in 2017 as well. The rides increase in the peak seasons and then reduce to zero in the winter months.
We have a basic pattern. Now let's see the average number.*/


-- Average no of trips a day for each year- month combination --
SELECT a.year, a.month, round(sum(total_trips)/COUNT(day)) as avg_trips_per_month
FROM
(SELECT year(start_date) as year, monthname(start_date) as month, day(start_date) as day, COUNT(1) as total_trips
FROM trips
GROUP BY year, month, day) as a
GROUP BY a.year, a.month;
/* We used a subquery here. The data was grouped by year, month and day respectively. It gave us a total of trips per day.
The output of the table was used as an input for the final solution. The sum of total trips per day was calculated for average trips per month.
To avoid the average trips in decimal, we used the round function and here is the output. 
RESULT:
   +------------------------------------------------------+
   |    year    |    month    |     avg_trips_per_month   |
   +------------------------------------------------------+
   |    2016    |    April    |             11870         |
   +------------------------------------------------------+
   |    2016    |     May     |             18099         |
   +------------------------------------------------------+
   |    2016    |     June    |             21050         |
   +------------------------------------------------------+
   |    2016    |     July    |             22556         |
   +------------------------------------------------------+
   |    2016    |    August   |             21703         |
   +------------------------------------------------------+
   |    2016    |  September  |             20675         |
   +------------------------------------------------------+
   |    2016    |   October   |             12661         |
   +------------------------------------------------------+
   |    2016    |   November  |             10009         |
   +------------------------------------------------------+
   |    2017    |    April    |             12229         |
   +------------------------------------------------------+
   |    2017    |     May     |             18950         |
   +------------------------------------------------------+
   |    2017    |     June    |             24728         |
   +------------------------------------------------------+
   |    2017    |     July    |             27766         |
   +------------------------------------------------------+
   |    2017    |    August   |             27095         |
   +------------------------------------------------------+
   |    2017    |  September  |             24395         |
   +------------------------------------------------------+
   |    2017    |   October   |             18049         |
   +------------------------------------------------------+
   |    2017    |   November  |             9986          |
   +------------------------------------------------------+
   It looks like the pattern is the same as that of the total trips per month.
   There is increase in average rides a day as summer months starts. A decline in average rides per day has been seen as fall approaches.
*/

-- We have some information about the seasonality of trips. Let's find out how membership status is reflected. --

-- Total trips by membership status--
SELECT year(start_date), if(is_member = 1, 'Member', 'Non-member') as membership_status
, count(*) as total_trips
FROM Trips
GROUP BY year(start_date), is_member;
/* RESULT:
   +--------------------------------------------------------+
   |    year    |    membership_status    |   num_of_trips  |
   +--------------------------------------------------------+
   |    2016    |          Member         |     3174660     |
   +--------------------------------------------------------+
   |    2016    |        Non-Member       |      742741     |
   +--------------------------------------------------------+
   |    2017    |          Member         |     3784682     |
   +--------------------------------------------------------+
   |    2017    |        Non-Member       |      882083     |
   +--------------------------------------------------------+
   The data for 'is_member' is binary: 1 or 0. So in the if statement, when the input was 1, we considered it as a member, otherwise we considered it as a non-member.
   Total tirps have increased in 2017 irrespective of the membership status. The majority of the trips are done by members.
*/


-- Fraction of total trips done by members in 2016 broken down by month --
/* To solve the query, we created 2 tables. The first table 'member_data' includes the total trips done by members in the respective year per month.
    The second table 'trips_data' includes the total trips done in a year per month.
    Both the tables were joined on the 'month' columns. The final table was used to calculate the ratio of members' trips to total trips per month in a year.
*/

SELECT member_data.month, member_data.member_trips / trips_data.total_trips AS member_fraction_by_month
FROM 
	(SELECT monthname(start_date) as month, COUNT(*) AS member_trips
	FROM trips
	WHERE YEAR(start_date) = 2016 AND is_member = 1
	GROUP BY month) AS member_data
JOIN 
	(SELECT MONTHNAME(start_date) AS month, COUNT(*) AS total_trips
    FROM trips
    WHERE YEAR(start_date) = 2016
    GROUP BY month) AS trips_data
ON member_data.month = trips_data.month;
/* RESULT:
   +--------------------------------------------+
   |    month      |   member_fraction_by_month |
   +--------------------------------------------+
   |    April      |           0.83517           |
   +--------------------------------------------+
   |    May        |           0.8109           |
   +--------------------------------------------+
   |    June       |           0.8088           |
   +--------------------------------------------+
   |    July       |           0.7687           |
   +--------------------------------------------+
   |    August     |           0.7739           |
   +--------------------------------------------+
   |    September  |           0.8202           |
   +--------------------------------------------+
   |    October    |           0.8747           |
   +--------------------------------------------+
   |    November   |           0.9119           |
   +--------------------------------------------+
*/

-- Fraction of total trips done by members in 2017 broken-down by month --
SELECT member_data.month, member_data.member_trips / trips_data.total_trips AS member_fraction_by_month
FROM 
	(SELECT monthname(start_date) as month, COUNT(*) AS member_trips
	FROM trips
	WHERE YEAR(start_date) = 2017 AND is_member = 1
	GROUP BY month) AS member_data
JOIN 
	(SELECT MONTHNAME(start_date) AS month, COUNT(*) AS total_trips
    FROM trips
    WHERE YEAR(start_date) = 2017
    GROUP BY month) AS trips_data
ON member_data.month = trips_data.month;
/* RESULT:
   +--------------------------------------------+
   |    month      |   member_fraction_by_month |
   +--------------------------------------------+
   |    April      |           0.8352           |
   +--------------------------------------------+
   |    May        |           0.8197           |
   +--------------------------------------------+
   |    June       |           0.8081           |
   +--------------------------------------------+
   |    July       |           0.7643           |
   +--------------------------------------------+
   |    August     |           0.7811           |
   +--------------------------------------------+
   |    September  |           0.8258           |
   +--------------------------------------------+
   |    October    |           0.8641           |
   +--------------------------------------------+
   |    November   |           0.9246           |
   +--------------------------------------------+
As expected, we can see similar trends for both years. The ratio decreases every month until October and suddenly increases in November. 
We may need to check the reasons behind the trend but it's out of the scope of the database.
*/

-- We now have trends about seasonality and membership status. Let's see if there are any patterns in the use of bike stations.--
-- Five most popular starting stations --
SELECT t.start_station_code, s.name as station_name, total_trips
FROM
(SELECT start_station_code, COUNT(1) AS total_trips
FROM trips
GROUP BY start_station_code) AS t
JOIN stations s ON t.start_station_code = s.code
ORDER BY total_trips DESC
LIMIT 5;
/* RESULT:
   +-----------------------------------------------------------------------------------------------------------+
   |    start_station_code  |                    station_name                        |       total_trips       |
   +-----------------------------------------------------------------------------------------------------------+
   |         6100           |               Mackay/ de Maisonneuve                   |           97150         |
   +-----------------------------------------------------------------------------------------------------------+
   |         6184           |      Metro Mont-Royal (Rivard/ du Mont-Royal)          |           81279         |
   +-----------------------------------------------------------------------------------------------------------+
   |         6078           |   Metro Place-des-Arts (de Maisonneuvre / de Bleury    |           78848         |
   +-----------------------------------------------------------------------------------------------------------+
   |         6136           |          Metro Laurier (Rivard/ Laurier)               |           76813         |
   +-----------------------------------------------------------------------------------------------------------+
   |         6064           |        Metro Peel (de Maisonneuve/ Stanley)            |           72298         |
   +-----------------------------------------------------------------------------------------------------------+
Interesting! 4 out of 5 stations are metro stations. 
*/

-- Let's traffic at the most popular station
-- Number of starts and ends distributed for the station Mackay/ de Maisonneuve throughout the day--
SELECT start_trips.time_of_day, start_trips.start_total_trips, end_trips.end_total_trips
FROM 
(SELECT COUNT(1) AS start_total_trips, CASE
WHEN HOUR(start_date) BETWEEN 7 AND 11 THEN "morning"
WHEN HOUR(Start_date) BETWEEN 12 AND 16 THEN "afternoon"
WHEN HOUR(start_date) BETWEEN 17 AND 21 THEN "evening"
ELSE "night"
END AS "time_of_day" 
FROM trips
WHERE start_station_code = 6100
GROUP BY time_of_day) as start_trips
JOIN
(SELECT COUNT(1) AS end_total_trips, CASE
WHEN HOUR(end_date) BETWEEN 7 AND 11 THEN "morning"
WHEN HOUR(end_date) BETWEEN 12 AND 16 THEN "afternoon"
WHEN HOUR(end_date) BETWEEN 17 AND 21 THEN "evening"
ELSE "night"
END AS "time_of_day" 
FROM trips
WHERE end_station_code = 6100
GROUP BY time_of_day) as end_trips
ON start_trips.time_of_day = end_trips.time_of_day;
/* We created 2 tables: one for the trips starting and one for the trips ending at the Mackay/ de Maisonneuve station.
Case when statements were used to find out traffic at different hours in a day. The hours of a day were defined as:
When the trip start time or end time is between 7 and 11 AM, consider it as a morning.
When the trip start time or end time is between 12 and 4 PM, consider it as an afternoon.
When the trip start time or end time is between 5 and 9 PM, consider it as an evening.
When the trip starts time or ends time is after 10 PM, consider it as a night.
RESULT:
   +-----------------------------------------------------+
   | time_of_day | start_total_trips |  end_total_trips  |
   +-----------------------------------------------------+
   |   morning   |       17384       |       26390       |    
   +-----------------------------------------------------+
   |  afternoon  |       30718       |       30429       |
   +-----------------------------------------------------+
   |  evening    |       36781       |       31983       |
   +-----------------------------------------------------+
   |    night    |       12267       |       10326       |
   +-----------------------------------------------------+
The number of trips is increasing as the day goes by and then starts decreasing at night. 
More trips are ending in the morning compared to those which start at the station. 
The total number of trips ending in the evening and night is less than those starting at the same time.
People may be taking bike rides to come to the station to attend university nearby hence more trips in the morning.
Once the classes are over, people take the bikes to ride back which makes the evening and night rides less in the numbers.
*/

-- We got the information about the most popular station, let's find some relationships for other stations. --
-- No. of starting trips per station--
SELECT t.start_station_code, s.name, total_trips
FROM
(SELECT start_station_code, COUNT(1) AS total_trips
FROM trips
GROUP BY start_station_code) AS t
JOIN stations s ON t.start_station_code = s.code
ORDER BY total_trips DESC;
-- As expected the most popular station is Mackay/ de Maisonneuve. We will check more details in a report.--

-- Total no of round trips for each station--
SELECT start_station_code, COUNT(1) AS total_round_trips
FROM trips
WHERE start_station_code = end_station_code
GROUP BY start_station_code
ORDER BY total_round_trips DESC;
-- The total no of stations for starting trips is the same as the total no of stations for round trips. The sequence of stations and total no of trips are different though. --

-- Fraction of round trips to total starting trips for each station --
SELECT a.start_station_code as station_code, a.total_round_trips/b.total_trips AS fraction
FROM
(SELECT start_station_code, COUNT(1) AS total_round_trips
FROM trips
WHERE start_station_code = end_station_code
GROUP BY start_station_code) AS a
JOIN
(SELECT start_station_code, COUNT(1) AS total_trips
FROM trips
GROUP BY start_station_code) AS b
ON a.start_station_code = b.start_station_code;
/* We combined the above two queries here. We calculated the total round trips in table 'a' by providing a condition of the same starting and ending stations.
Total starting trips were calculated in table 'b'. 
The tables were combined to find out the fraction of round trips by total starting trips for each station.
We will check the result in a report.
*/

-- We have a good knowledge of rides at different stations. Let's focus on the high-traffic stations now. --
-- Stations with at least 500 starting trips and at least 10% round trips--
SELECT a.start_station_code, a.name, a.total_round_trips/b.total_trips AS fraction_of_trips
FROM
(SELECT t.start_station_code, s.name, total_round_trips                 
	FROM
	(SELECT start_station_code, COUNT(1) AS total_round_trips     -- displays starting station code and total round trips
	FROM trips
	WHERE start_station_code = end_station_code
	GROUP BY start_station_code) AS t
	JOIN stations s ON t.start_station_code = s.code              -- The trips table is joined to the stations table to get the stations name
	ORDER BY total_round_trips DESC) AS a
INNER JOIN                                                        -- the above round trips table is joined to the total trips table
	(SELECT t.start_station_code, s.name, total_trips             -- displays starting station code and total trips
	FROM
	(SELECT start_station_code, COUNT(1) AS total_trips
	FROM trips
	GROUP BY start_station_code) AS t
	JOIN stations s ON t.start_station_code = s.code              -- The trips table is joined to the stations table to get the stations name
	ORDER BY total_trips DESC) AS b
ON a.start_station_code = b.start_station_code                     -- the round trips table and total trips table is joined on the station codes
WHERE b.total_trips >= 500 AND a.total_round_trips/b.total_trips >= 0.1  -- the condition of more than 500 total trips and min 10% round trips is applied
ORDER BY  fraction_of_trips DESC;
# total such stations= 14. We will check the details in a report.
/*
Here, two tables are created in subqueries. The first table 'a' is for the round trips and the second table 'b' is for the total trips.
Each subquery table (tables a and b) result is joined with the stations' table to get the stations' names.
Finally, these 2 tables were combined by an inner join, added the required condition by where clause and the result were displayed.
*/

/* We have explored the database. We have exported the results of the last few queries. We will visualize the results of all the queries and will see what insights
we can get from that. */

