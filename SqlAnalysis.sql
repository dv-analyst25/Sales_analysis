--   -------------DATABASE -----------------
create database Swiggy_db;
use Swiggy_db;
-- ------------MODIFIED RAW DATA -----------

select * from orders;
select count(*) from orders;


describe orders;

ALTER TABLE orders
CHANGE `Dish Name` dish_name VARCHAR(200),
CHANGE `Rating Count` rating_count INT,
CHANGE `Price (INR)` price_inr DECIMAL(10,2);



ALTER TABLE orders
MODIFY price_inr DECIMAL(10,2), 
MODIFY rating DECIMAL(3,2),
MODIFY rating_count INT;

select * from orders ;
describe orders;

ALTER TABLE orders
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY;

select order_date from orders;
-- checking dates
SELECT
    COUNT(*) AS total_rows,
    SUM(order_date REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$') AS dd_mm_yyyy_dash,
    SUM(order_date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$') AS dd_mm_yyyy_slash,
    SUM(order_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$') AS yyyy_mm_dd,
    SUM(order_date REGEXP '^[A-Za-z]+ [0-9]{1,2} [0-9]{4}$') AS month_name_format,
    SUM(order_date NOT REGEXP '(^[0-9]{2}[-/][0-9]{2}[-/][0-9]{4}$|^[0-9]{4}-[0-9]{2}-[0-9]{2}$|^[A-Za-z]+ [0-9]{1,2} [0-9]{4}$)') AS invalid_rows
FROM orders;
ALTER TABLE orders
MODIFY order_date DATE;






SELECT * FROM orders;

--  ---------DATA CLEANGIN-------
-- null value check 
select 
SUM(CASE WHEN state IS NULL THEN 1 ELSE 0 END) as null_state,
SUM(CASE WHEN order_Date IS NULL THEN 1 ELSE 0 END) as null_order_date,
SUM(CASE WHEN restaurant_name IS NULL THEN 1 ELSE 0 END) as  null_restaurant_name,
SUM(CASE WHEN location IS NULL THEN 1 ELSE 0 END) as null_locaion,
SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) as null_category,
SUM(CASE WHEN dish_name IS NULL THEN 1 ELSE 0 END) as null_dish_name,
SUM(CASE WHEN price_inr IS NULL THEN 1 ELSE 0 END) as null_price_inr,
SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) as null_rating,
SUM(CASE WHEN rating_count IS NULL THEN 1 ELSE 0 END) as null_rating_count
FROM orders;

-- checking blank / empty spaces

SELECT
SUM(TRIM(state) = '')           AS blank_state,
SUM(TRIM(city) = '')            AS blank_city,
SUM(TRIM(category) = '')        AS blank_category,
SUM(TRIM(restaurant_name) = '') AS blank_restaurant_name,
SUM(TRIM(dish_name) = '')       AS blank_dish_name
FROM orders;
--  checking duplicate

SELECT
    state,
    city,
    category,
    restaurant_name,
    dish_name,
    order_date,
    price_inr,
    rating,
    rating_count,
    COUNT(*) AS duplicate_count
FROM orders
GROUP BY
    state,
    city,
    category,
    restaurant_name,
    dish_name,
    order_date,
    price_inr,
    rating,
    rating_count
HAVING COUNT(*) > 1;

-- deleting duplicate raws
WITH ranked_orders AS (
    SELECT
        id,
        ROW_NUMBER() OVER (
            PARTITION BY
                state,
                city,
                category,
                restaurant_name,
                dish_name,
                order_date,
                price_inr,
                rating,
                rating_count
            ORDER BY id
        ) AS rn
    FROM orders
)
DELETE o
FROM orders o
JOIN ranked_orders r
    ON o.id = r.id
WHERE r.rn > 1;


--  --------------------DIMENTION TABLES------------


CREATE TABLE dim_date (
    date_id INT AUTO_INCREMENT PRIMARY KEY,
    full_date DATE NOT NULL,
    year INT NOT NULL,
    month INT NOT NULL,
    month_name VARCHAR(10),
    quarter INT ,
    day INT ,
    week INT
);

CREATE TABLE dim_location (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    state VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    location VARCHAR(200)
);

CREATE TABLE dim_restaurant (
    restaurant_id INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_name VARCHAR(200) NOT NULL
);

CREATE TABLE dim_dish (
    dish_id INT AUTO_INCREMENT PRIMARY KEY,
    dish_name VARCHAR(200) NOT NULL
);

CREATE TABLE dim_category (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL
);
-- ---------------------FACT TABLE------------

CREATE TABLE fact_orders (
    order_id BIGINT AUTO_INCREMENT PRIMARY KEY,

    date_id INT NOT NULL,
    location_id INT NOT NULL,
    restaurant_id INT NOT NULL,
    dish_id INT NOT NULL,
    category_id INT NOT NULL,

    price_inr DECIMAL(10,2),
    rating DECIMAL(3,2),
    rating_count INT,

   
    CONSTRAINT fk_fact_date
        FOREIGN KEY (date_id) REFERENCES dim_date(date_id),

    CONSTRAINT fk_fact_location
        FOREIGN KEY (location_id) REFERENCES dim_location(location_id),

    CONSTRAINT fk_fact_restaurant
        FOREIGN KEY (restaurant_id) REFERENCES dim_restaurant(restaurant_id),

    CONSTRAINT fk_fact_dish
        FOREIGN KEY (dish_id) REFERENCES dim_dish(dish_id),

    CONSTRAINT fk_fact_category
        FOREIGN KEY (category_id) REFERENCES dim_category(category_id)
);

SELECT * FROM fact_orders;



-- =======================
-- INDEXES (LOGICAL & MINIMAL)
-- =======================

-- For Time-based analysis 
CREATE INDEX idx_fact_date
ON fact_orders(date_id);

-- For Location-based analysis 
CREATE INDEX idx_fact_location
ON fact_orders(location_id);

-- For Restaurant performance analysis
CREATE INDEX idx_fact_restaurant
ON fact_orders(restaurant_id);

-- For Dish-level demand analysis
CREATE INDEX idx_fact_dish
ON fact_orders(dish_id);

-- For Category-wise performance
CREATE INDEX idx_fact_category
ON fact_orders(category_id);


-- ---------------INSERTING DATA IN TABLES------------- 


INSERT INTO dim_date (
    full_date,
    year,
    month,
    month_name,
    quarter,
    day,
    week
)
SELECT DISTINCT
    order_date,
    YEAR(order_date),
    MONTH(order_date),
    MONTHNAME(order_date),
    QUARTER(order_date),
    DAY(order_date),
    WEEK(order_date)
FROM orders
WHERE order_date IS NOT NULL;

SELECT * FROM dim_date;

INSERT INTO dim_location (state, city, location)
SELECT DISTINCT
    state,
    city,
    location
FROM orders
WHERE state IS NOT NULL
  AND city IS NOT NULL;
  
  SELECT * FROM dim_location;

INSERT INTO dim_restaurant (restaurant_name)
SELECT DISTINCT
    restaurant_name
FROM orders
WHERE restaurant_name IS NOT NULL;

SELECT * FROM dim_restaurant;

INSERT INTO dim_dish (dish_name)
SELECT DISTINCT
    dish_name
FROM orders
WHERE dish_name IS NOT NULL;

SELECT * FROM dim_dish;

INSERT INTO dim_category (category_name)
SELECT DISTINCT
    category
FROM orders
WHERE category IS NOT NULL;

SELECT * FROM dim_category;
TRUNCATE TABLE fact_orders;
select * from fact_orders;
INSERT INTO fact_orders (
    date_id,
    location_id,
    restaurant_id,
    dish_id,
    category_id,
    price_inr,
    rating,
    rating_count
)
SELECT
    dd.date_id,
    dl.location_id,
    dr.restaurant_id,
    ddi.dish_id,
    dc.category_id,
    o.price_inr,
    o.rating,
    o.rating_count
FROM orders o
JOIN dim_date dd
    ON o.order_date = dd.full_date
JOIN dim_location dl
    ON o.state = dl.state
   AND o.city = dl.city
   AND o.location = dl.location
JOIN dim_restaurant dr
    ON o.restaurant_name = dr.restaurant_name
JOIN dim_dish ddi
    ON o.dish_name = ddi.dish_name
JOIN dim_category dc
    ON o.category = dc.category_name;

SELECT * FROM fact_orders;

-- --------------IMPORTANT JOINS-----
SELECT *
FROM fact_orders f
JOIN dim_date d        ON f.date_id = d.date_id
JOIN dim_location l    ON f.location_id = l.location_id
JOIN dim_restaurant r  ON f.restaurant_id = r.restaurant_id
JOIN dim_dish di       ON f.dish_id = di.dish_id
JOIN dim_category c    ON f.category_id = c.category_id;


-- ---------- BASIC KPIs ----------

-- Total Orders
SELECT COUNT(*) AS total_orders
FROM fact_orders;

-- Total Revenue (INR Million)
SELECT ROUND(SUM(price_inr) / 1000000, 2) AS total_revenue_million
FROM fact_orders;

-- Average Dish Price
SELECT ROUND(AVG(price_inr), 2) AS avg_dish_price
FROM fact_orders
WHERE price_inr IS NOT NULL;

-- Average Rating
SELECT ROUND(AVG(rating), 2) AS avg_rating
FROM fact_orders
WHERE rating IS NOT NULL;


-- ---------- DATE-BASED ANALYSIS ----------

-- Monthly Order Trends
SELECT
    d.year,
    d.month_name,
    COUNT(*) AS total_orders
FROM fact_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;

-- Quarterly Order Trends
SELECT
    d.year,
    d.quarter,
    COUNT(*) AS total_orders
FROM fact_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year, d.quarter
ORDER BY d.year, d.quarter;

-- Year-wise Growth
SELECT
    d.year,
    COUNT(*) AS total_orders
FROM fact_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year
ORDER BY d.year;

-- Day-of-Week Pattern
SELECT
    d.week AS day_of_week,
    COUNT(*) AS total_orders
FROM fact_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.week
ORDER BY d.week;


-- ---------- LOCATION-BASED ANALYSIS ----------

-- Top 10 Cities by Order Volume
SELECT
    l.city,
    COUNT(*) AS total_orders
FROM fact_orders f
JOIN dim_location l ON f.location_id = l.location_id
GROUP BY l.city
ORDER BY total_orders DESC
LIMIT 10;

-- Revenue Contribution by State
SELECT
    l.state,
    ROUND(SUM(f.price_inr), 2) AS revenue
FROM fact_orders f
JOIN dim_location l ON f.location_id = l.location_id
GROUP BY l.state
ORDER BY revenue DESC;


-- ---------- FOOD PERFORMANCE ----------

-- Top 10 Restaurants by Orders
SELECT
    r.restaurant_name,
    COUNT(*) AS total_orders
FROM fact_orders f
JOIN dim_restaurant r ON f.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_name
ORDER BY total_orders DESC
LIMIT 10;

-- Category-wise Orders
SELECT
    c.category_name,
    COUNT(*) AS total_orders
FROM fact_orders f
JOIN dim_category c ON f.category_id = c.category_id
GROUP BY c.category_name
ORDER BY total_orders DESC;


-- Most Ordered Dishes
SELECT
    dsh.dish_name,
    COUNT(*) AS total_orders
FROM fact_orders f
JOIN dim_dish dsh ON f.dish_id = dsh.dish_id
GROUP BY dsh.dish_name
ORDER BY total_orders DESC
LIMIT 10;

-- Category Performance 
SELECT
    c.category_name,
    COUNT(*) AS total_orders,
    ROUND(AVG(f.rating), 2) AS avg_rating
FROM fact_orders f
JOIN dim_category c ON f.category_id = c.category_id
WHERE f.rating IS NOT NULL
GROUP BY c.category_name
ORDER BY total_orders DESC;


-- ---------- CUSTOMER SPENDING INSIGHTS ----------

SELECT MIN(price_inr) FROM orders;
-- Spend Buckets
SELECT
    CASE
        WHEN price_inr < 100 THEN 'Under 100'
        WHEN price_inr BETWEEN 100 AND 499 THEN '100-499'
        WHEN price_inr BETWEEN 500 AND 999 THEN '500-999'
        WHEN price_inr BETWEEN 1000 AND 4999 THEN '1000-4999'
        ELSE '5000+'
    END AS spend_bucket,
    COUNT(*) AS total_orders
FROM fact_orders
GROUP BY spend_bucket
ORDER BY total_orders DESC;


-- ---------- RATINGS ANALYSIS ----------

-- Rating Distribution (out of 5)
SELECT
    rating,
    COUNT(*) AS total_orders
FROM fact_orders
WHERE rating IS NOT NULL
GROUP BY rating
ORDER BY rating;


SELECT COUNT(*) FROM fact_orders WHERE date_id IS NULL;
SELECT COUNT(*) FROM fact_orders WHERE location_id IS NULL;

