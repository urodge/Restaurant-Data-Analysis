Create Database cognify;
use cognify;
CREATE TABLE restaurants (
    restaurant_id INT,
    restaurant_name VARCHAR(255),
    country_code INT,
    city VARCHAR(255),
    address TEXT,
    locality VARCHAR(255),
    locality_verbose TEXT,
    longitude FLOAT,
    latitude FLOAT,
    cuisines TEXT,
    average_cost_for_two INT,
    currency VARCHAR(50),
    has_table_booking VARCHAR(3),
    has_online_delivery VARCHAR(3),
    is_delivering_now VARCHAR(3),
    switch_to_order_menu VARCHAR(3),
    price_range INT,
    aggregate_rating FLOAT,
    rating_color VARCHAR(50),
    rating_text VARCHAR(50),
    votes INT
);

select * from restaurants;

-- Level 1

-- Task1: Top Cuisines

-- Determine the top three most common cuisines in the dataset.

CREATE TABLE numbers (n INT);
INSERT INTO numbers (n) VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10);
SELECT cuisine, COUNT(restaurant_id) AS count_cuisines
FROM (
    SELECT 
        restaurant_id, 
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cuisines, ', ', numbers.n), ', ', -1)) AS cuisine
    FROM 
        restaurants
    JOIN 
        numbers ON CHAR_LENGTH(cuisines) - CHAR_LENGTH(REPLACE(cuisines, ', ', '')) >= numbers.n - 1
) AS cuisines_exploded
GROUP BY cuisine
ORDER BY count_cuisines DESC
LIMIT 3;

-- Calculate the percentage of restaurants that serve each of the top cuisines.

SELECT 
    cuisine, 
    COUNT(restaurant_id) AS cuisine_count,
    (COUNT(restaurant_id) / (SELECT COUNT(*) FROM restaurants) * 100) AS count_cuisines
FROM (
    SELECT 
        restaurant_id, 
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cuisines, ', ', numbers.n), ', ', -1)) AS cuisine
    FROM 
        restaurants
    JOIN 
        numbers ON CHAR_LENGTH(cuisines) - CHAR_LENGTH(REPLACE(cuisines, ', ', '')) >= numbers.n - 1
) AS cuisines_exploded
GROUP BY cuisine
ORDER BY cuisine_count DESC
LIMIT 4;


-- Step 1: Explode cuisines into individual rows
WITH cuisines_exploded AS (
    SELECT 
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(r.cuisines, ', ', n.n), ', ', -1)) AS cuisine,
        r.restaurant_id
    FROM 
        restaurants r
    JOIN 
        numbers n ON CHAR_LENGTH(r.cuisines) - CHAR_LENGTH(REPLACE(r.cuisines, ', ', '')) >= n.n - 1
),
-- Step 2: Count occurrences of each cuisine
cuisine_counts AS (
    SELECT 
        cuisine,
        COUNT(restaurant_id) AS cuisine_count
    FROM 
        cuisines_exploded
    GROUP BY 
        cuisine
),
-- Step 3: Total number of restaurants
total_restaurants AS (
    SELECT COUNT(*) AS total_count FROM restaurants
)

-- Step 4: Final select with percentage calculation
SELECT 
    cc.cuisine,
    cc.cuisine_count,
    (cc.cuisine_count / tr.total_count) * 100 AS percentage
FROM 
    cuisine_counts cc, total_restaurants tr
ORDER BY 
    cc.cuisine_count DESC
LIMIT 4;


-- Task 2: City Analysis

-- Identify the city with the highest numberof restaurants in the dataset.
select city, count(restaurant_id) as count_city
from restaurants
group by city
order by count_city desc
limit 1;


-- Calculate the average rating for restaurants in each city.

select city, avg(aggregate_rating) as Avg_rating
from restaurants
group by city
order by city ;

-- Determine the city with the highest average rating.

select city, avg(aggregate_rating) as Avg_rating
from restaurants
group by city
order by Avg_rating desc
limit 1;


-- Task 3: Price Range Distribution

-- Calculate the percentage of restaurants in each price range category.

SELECT 
    cuisine, 
    COUNT(restaurant_id) AS cuisine_count,
    (COUNT(restaurant_id) / (SELECT COUNT(*) FROM restaurants) * 100) AS count_cuisines
FROM (
    SELECT 
        restaurant_id, 
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cuisines, ', ', numbers.n), ', ', -1)) AS cuisine
    FROM 
        restaurants
    JOIN 
        numbers ON CHAR_LENGTH(cuisines) - CHAR_LENGTH(REPLACE(cuisines, ', ', '')) >= numbers.n - 1
) AS cuisines_exploded
GROUP BY cuisine
ORDER BY cuisine_count DESC
LIMIT 4;

-- Task 4: Online Delivery

-- Determine the percentage of restaurants that offer online delivery.
WITH count_online_delivery AS (
    SELECT has_online_delivery, COUNT(*) AS count_id
    FROM restaurants
    GROUP BY has_online_delivery
),
total_count AS (
    SELECT COUNT(*) AS total_id_count FROM restaurants
)
SELECT 
    od.has_online_delivery,
    od.count_id,
    CONCAT(ROUND((od.count_id / tc.total_id_count) * 100, 2), '%') AS percentage
FROM 
    count_online_delivery AS od, total_count AS tc;
    

-- Compare the average ratings of restaurants with and without online delivery.

SELECT 
    has_online_delivery,  
    ROUND(AVG(aggregate_rating), 2) AS avg_rating
FROM 
    restaurants
GROUP BY 
    has_online_delivery;
    
    
    
-- level 2

-- Task 1: Restaurant Ratings

-- Analyze the distribution of aggregateratings and determine the most common rating range.

select aggregate_rating,
count(*) as count_rating
from restaurants
group by aggregate_rating
order by count_rating desc;

-- Calculate the average number of votes received by restaurants.

select avg(votes) as avg_votes
from restaurants;

-- Task 2: Cuisine Combination

-- Identify the most common combinations of cuisines in the dataset.

SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cuisines, ', ', numbers.n), ', ', -1)) AS cuisine,
    COUNT(*) AS count_cuisines
FROM 
    restaurants
JOIN 
    numbers ON CHAR_LENGTH(cuisines) - CHAR_LENGTH(REPLACE(cuisines, ', ', '')) >= numbers.n - 1
GROUP BY 
    cuisine
ORDER BY 
    count_cuisines DESC;


-- Determine if certain cuisine combinations tend to have higher ratings.

select cuisines ,count(aggregate_rating) as higher_rating
from restaurants
group by cuisines
order by higher_rating desc;

-- Task 4: Restaurant Chains

-- Identify if there are any restaurant chains present in the dataset.


select restaurant_name, count(restaurant_name) as count_restaurant
from restaurants
group by restaurant_name
having count(restaurant_name)>1
order by count_restaurant desc;

-- Analyze the ratings and popularity of different restaurant chains.

select restaurant_name, count(restaurant_name) as num_restaurant, avg(aggregate_rating) as Avg_rating,sum(votes) as total_votes
from restaurants
group by restaurant_name
having count(restaurant_name)>1
order by Avg_rating desc,total_votes desc;

   -- level 3

-- Task 1: Restaurant Reviews

-- Calculate the average length of reviews and explore if there is a relationship between review length and rating.

select aggregate_rating,avg(length(rating_text))
from restaurants
group by aggregate_rating
order by aggregate_rating desc;

-- Task 2: Votes Analysis

-- Identify the restaurants with the highest and lowest number of votes.

-- Identify the restaurants with the highest and lowest number of votes.

-- Identify the restaurants with the highest and lowest number of votes.

(SELECT restaurant_name, votes, 'highest' AS vote_rank
 FROM restaurants
 ORDER BY votes DESC
 LIMIT 1)
UNION ALL
(SELECT restaurant_name, votes, 'lowest' AS vote_rank
 FROM restaurants
 ORDER BY votes ASC
 LIMIT 1);

-- Analyze if there is a correlation between the number of votes and the rating of a restaurant.
											 
-- Calculate the correlation coefficient between votes and aggregate_rating

SELECT 
    (COUNT(*) * SUM(votes * aggregate_rating) - SUM(votes) * SUM(aggregate_rating)) / 
    (SQRT((COUNT(*) * SUM(votes * votes) - SUM(votes) * SUM(votes)) * (COUNT(*) * SUM(aggregate_rating * aggregate_rating) - SUM(aggregate_rating) * SUM(aggregate_rating)))) AS correlation_coefficient
FROM 
    restaurants;
    
    -- Task 2: Price Range vs. Online Delivery and Table Booking


-- Analyze if there is a relationship between the price range and the availability of online delivery and table booking.


SELECT price_range, COUNT(*) AS total_restaurants,
    round(avg(CASE WHEN has_online_delivery = 'Yes' THEN 1 ELSE 0 END),3)AS delivery_available,
    round(avg(CASE WHEN has_table_booking = 'Yes' THEN 1 ELSE 0 END),3) AS booking_available
FROM restaurants
GROUP BY price_range;

-- Determine if higher-priced restaurants are more likely to offer these services.

-- this is for online_delivery
select has_online_delivery, count(price_range) as higher_price_count
from restaurants
where price_range =4
GROUP BY has_online_delivery;

-- this is for table_booking
select has_table_booking, count(price_range) as higher_price_count
from restaurants
where price_range =4
GROUP BY has_table_booking;



