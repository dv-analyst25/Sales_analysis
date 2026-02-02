# Swiggy Data Analysis (SQL + Power BI)

This project contains my complete analysis of Swiggy-style food delivery data using SQL. I cleaned the raw data, fixed inconsistent formats, removed duplicates, created dimension & fact tables (Star Schema), and generated KPIs. I also built a Power BI dashboard based on the final transformed data. This project helped me practice SQL for real-world analytics.

 # Project Overview

Raw data cleaning and preprocessing.
Handling date formats.
Null and blank value checks.
Duplicate removal.
Creating dimension tables.
Creating fact_orders table.
Adding indexes for optimization.
KPI and trend analysis queries.
Power BI Dashboard (pbix file included).



# Data Cleaning Summary

Converted mixed date formats (dd-mm-yyyy, dd/mm/yyyy, month dd yyyy) into proper DATE format.
Checked nulls for state, city, restaurant_name, category, dish_name, price, rating, rating_count.
Checked blank values using TRIM().
Removed duplicates using ROW_NUMBER().

# Star Schema Model
Dimension Tables-
dim_date
dim_location
dim_restaurant
dim_dish
dim_category

Fact Table-
fact_orders containing:
date_id, location_id, restaurant_id, dish_id, category_id, price_inr, rating, rating_count


# KPIs & Main Analysis
Basic Metrics-
Total Orders
Total Revenue
Average Dish Price
Average Rating

Analysis-
Time-Based Trends
Monthly and Quarterly trends
Year-wise order growth
Weekday patterns
Location Analysis
Top 10 cities by orders
State-wise revenue
Food & Restaurant Insights
Most ordered dishes
Category-wise performance
Top restaurants
Category-level ratings
Spend Buckets
Under ₹100
₹100–₹499
₹500–₹999
₹1000–₹4999
₹5000+

# Power BI Dashboard

The Power BI dashboard contains visuals for order trends, revenue, state-wise distribution, category performance, and customer spend behavior.
The .pbix file and screenshots are inside the powerbi folder.

# Why I Built This

I created this project to improve my SQL skills, understand dimensional modeling, and learn how real business reporting works using SQL + Power BI. This helped me practice data cleaning, joins, transformations, and dashboard building.

# Feedback

I’m still learning SQL and analytics, so any feedback or improvements are welcome.
