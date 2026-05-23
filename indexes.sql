--Query 1: Product Search
--Before Optimization
SELECT *
FROM Ad
WHERE category_id = 30
AND location_id = 2
AND price < 10000;
--Problem
--Full table scan.
--Slow performance with large datasets.
--After Optimization
CREATE INDEX idx_search_ads
ON Ad(category_id, location_id, price);
SELECT ad_id, title, price
FROM Ad
WHERE category_id = 39
AND location_id = 2
AND price < 10000;
--Improvement
--Faster search performance.
--Reduced query execution time.
--Reduced unnecessary column retrieval.


--Query 2: Retrieve User Advertisements
--Before Optimization
SELECT *
FROM Ad
WHERE user_id = 5;
--After Optimization
CREATE INDEX idx_ad_user
ON Ad(user_id);
SELECT ad_id, title, price, status
FROM Ad
WHERE user_id = 5;
--Improvement
--Faster retrieval of seller advertisements.
--Better performance for user dashboards.

--Query 3: Most Viewed Advertisements Report
--Before Optimization
SELECT *
FROM Ad
ORDER BY views_count DESC;
--After Optimization
CREATE INDEX idx_views
ON Ad(views_count DESC);
SELECT TOP 10 title, price, views_count
FROM Ad
ORDER BY views_count DESC;
--Improvement
--Faster sorting operation.
--Efficient generation of analytics reports.

--4. Index on User ID
--Before Optimization
SELECT *
FROM Ad
WHERE user_id = 5;
--Problem
--Slow retrieval of advertisements created by users.
--Full table scan affects dashboard performance.
--After Optimization
CREATE INDEX idx_ad_user
ON Ad(user_id);
SELECT ad_id, title, price, status
FROM Ad
WHERE user_id = 5;
--Improvement
--Faster retrieval of seller advertisements.
--Improved user dashboard performance.
--Reduced query execution cost.

--5. Composite Index for Search Optimization
--Before Optimization
SELECT *
FROM Ad
WHERE category_id = 39
AND location_id = 2
AND price < 10000;
--Problem
--Multiple filtering conditions cause expensive table scans.
--Slow performance in advanced search operations.
--After Optimization
CREATE INDEX idx_search_ads
ON Ad(category_id, location_id, price);
SELECT ad_id, title, price
FROM Ad
WHERE category_id = 39
AND location_id = 2
AND price < 10000;
--Improvement
--Faster multi-condition search queries.
--Optimized filtering and sorting.
--Reduced execution time for advanced search operations.