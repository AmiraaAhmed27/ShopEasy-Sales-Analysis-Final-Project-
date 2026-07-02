--TABLE 1

SELECT * 
	FROM customers

--NO.customers

SELECT
     COUNT(*) AS Total_Customers 
FROM customers

--NULLS xxx  

--Duplicates

SELECT 
    Email,
    COUNT(*) AS Times_Repeated
FROM customers
GROUP BY Email
HAVING COUNT(*) > 1

--Age

SELECT 
    MIN(Age) AS Min_Age,
    MAX(Age) AS Max_Age,
    AVG(Age) AS Avg_Age
FROM customers

--Gender

SELECT 
    DISTINCT Gender,
    COUNT(*) AS Count
FROM customers
GROUP BY Gender

--Space

SELECT 
    CustomerID,
    CustomerName,
    Gender,
    LEN(CustomerName) AS Name_Length,
    LEN(LTRIM(RTRIM(CustomerName))) AS Name_Length_Trimmed
FROM customers
WHERE 
    LEN(CustomerName) != LEN(LTRIM(RTRIM(CustomerName)))
    OR LEN(Gender) != LEN(LTRIM(RTRIM(Gender)))

-- Email format

SELECT Email 
FROM customers
WHERE Email NOT LIKE '%@%.%'

--GeographyID 

SELECT c.CustomerID, c.GeographyID
FROM customers c
LEFT JOIN geography g 
ON c.GeographyID = g.GeographyID
WHERE g.GeographyID IS NULL

--NO.CustomerName

SELECT CustomerName
FROM customers
WHERE CustomerName LIKE '%[0-9]%'


-- Customer Age Segmentation

SELECT 
    CASE 
        WHEN Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN Age BETWEEN 36 AND 50 THEN '36-50'
        WHEN Age BETWEEN 51 AND 69 THEN '51-69'
    END AS AgeGroup,
    
    COUNT(*) AS CustomerCount,
CAST(CAST(ROUND(COUNT(*) * 100.0 / 
    (SELECT COUNT(*) FROM dbo.customers), 0) AS INT) 
    AS VARCHAR) + '%' AS Percentage

FROM dbo.customers

GROUP BY 
    CASE 
        WHEN Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN Age BETWEEN 36 AND 50 THEN '36-50'
        WHEN Age BETWEEN 51 AND 69 THEN '51-69'
    END

ORDER BY AgeGroup
----------
--TABLE 2 

SELECT  *
	FROM products

--NO.Product

SELECT
    COUNT(*) AS Total_Products 
FROM products

--Space

SELECT
    ProductID,
    ProductName
FROM products
WHERE LEN(ProductName) != LEN(TRIM(ProductName))

--Dublicates

SELECT 
    ProductName,
    COUNT(*) AS Times_Repeated
FROM products
GROUP BY ProductName
HAVING COUNT(*) > 1


-- Case inconsistency

SELECT
    DISTINCT ProductName
FROM products
WHERE ProductName != UPPER(LEFT(ProductName,1)) + LOWER(SUBSTRING(ProductName,2,LEN(ProductName)))

-- Case Sensitivity/Spaces
SELECT
    DISTINCT Category
FROM products
ORDER BY Category


-- NULLs.PRICE
SELECT *
FROM products 
WHERE Price IS NULL

-- PRICE = 0 OR -
SELECT *
FROM products 
WHERE Price <= 0 

--  Price Range , Outliers
SELECT  
    Category,
    MIN(Price) AS Min_Price,
    MAX(Price) AS Max_Price, 
    AVG(Price) AS Avg_Price
FROM products
GROUP BY Category


--TABLE 3


SELECT *
	FROM customer_journey 

    -- هل فيه أي CustomerID مش موجود في جدول الـ customers؟
SELECT 
    DISTINCT CustomerID
FROM customer_journey
WHERE CustomerID NOT IN (SELECT CustomerID FROM customers)

-- معرفة أنواع الـ Stages والـ Actions الموجودة
SELECT
    Stage, 
    Action, 
    COUNT(*) AS Frequency
FROM customer_journey
GROUP BY Stage, Action
ORDER BY Frequency DESC

-- كم نسبة الـ NULLs في الـ Duration؟
SELECT 
    COUNT(*) AS TotalRows,
    SUM(CASE WHEN Duration IS NULL THEN 1 ELSE 0 END) AS NullCount,
    CAST(SUM(CASE WHEN Duration IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(10,2)) AS NullPercentage
FROM customer_journey



SELECT*
FROM customer_journey
WHERE Duration IS NULL 


ALTER TABLE dbo.customer_journey
ADD is_dropoff BIT

UPDATE dbo.customer_journey
SET is_dropoff = CASE 
    WHEN Action = 'Drop-off' THEN 1
    ELSE 0
END
 
    SELECT 
    MIN(Duration) AS MinDuration,
    MAX(Duration) AS MaxDuration,
    AVG(Duration) AS AvgDuration
FROM customer_journey
WHERE Duration IS NOT NULL

SELECT 
    MIN(VisitDate) AS EarliestDate,
    MAX(VisitDate) AS LatestDate
FROM customer_journey

SELECT 
    CustomerID,
    ProductID, 
    VisitDate,
    Stage,
    COUNT(*) AS TimesRepeated
FROM customer_journey
GROUP BY CustomerID, ProductID, VisitDate, Stage
HAVING COUNT(*) > 1



WITH CTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY CustomerID, ProductID, VisitDate, Stage, Action, Duration
            ORDER BY JourneyID
        ) AS RowNum
    FROM dbo.customer_journey
)
SELECT COUNT(*) AS RowsToDelete
FROM CTE
WHERE RowNum > 1

SELECT 
    JourneyID,
    COUNT(*) AS Times_Repeated
FROM dbo.customer_journey
GROUP BY JourneyID
HAVING COUNT(*) > 1

WITH CTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY CustomerID, ProductID, VisitDate, Stage, Action, Duration
            ORDER BY JourneyID
        ) AS RowNum
    FROM dbo.customer_journey
)
DELETE FROM CTE
WHERE RowNum > 1

SELECT COUNT(*) AS TotalRows
FROM dbo.customer_journey

UPDATE dbo.customer_journey
SET Stage = CASE 
    WHEN LOWER(Stage) = 'homepage' THEN 'Homepage'
    WHEN LOWER(Stage) = 'productpage' THEN 'ProductPage'
    WHEN LOWER(Stage) = 'checkout' THEN 'Checkout'
END
WHERE Stage != CASE 
    WHEN LOWER(Stage) = 'homepage' THEN 'Homepage'
    WHEN LOWER(Stage) = 'productpage' THEN 'ProductPage'
    WHEN LOWER(Stage) = 'checkout' THEN 'Checkout'
END

SELECT DISTINCT Action
FROM dbo.customer_journey

SELECT  *
	FROM customer_reviews

--ReviewID Duplicates

SELECT
    ReviewID,
    COUNT(*) AS Times_Repeated
FROM customer_reviews
GROUP BY ReviewID
HAVING COUNT(*) > 1

--CustomerID FK

SELECT
    DISTINCT CustomerID
FROM customer_reviews
WHERE CustomerID NOT IN (SELECT CustomerID FROM customers)

--ProductID FK

SELECT
    DISTINCT ProductID
FROM customer_reviews
WHERE ProductID NOT IN (SELECT ProductID FROM products)

--ReviewDate Range

SELECT 
    MIN(ReviewDate) AS EarliestDate,
    MAX(ReviewDate) AS LatestDate
FROM customer_reviews

--Rating RangeSELECT 
SELECT
    MIN(Rating) AS MinRating,
    MAX(Rating) AS MaxRating
FROM customer_reviews

--Spaces — TRIM

UPDATE dbo.customer_reviews
SET ReviewText = TRIM(ReviewText)
WHERE LEN(ReviewText) != LEN(TRIM(ReviewText))

--Double Spaces — REPLACE

UPDATE dbo.customer_reviews
SET ReviewText = REPLACE(ReviewText, '  ', ' ')
WHERE ReviewText LIKE '%  %'

--Triple Spaces

SELECT
    COUNT(*) AS Still_Has_Double_Spaces
FROM customer_reviews
WHERE ReviewText LIKE '%  %'

--TABLE 4

SELECT  * 
	FROM engagement_data

 --EngagementID Duplicates

 SELECT 
    EngagementID,
    COUNT(*) AS TimesRepeated
FROM engagement_data
GROUP BY EngagementID
HAVING COUNT(*) > 1

-- ContentType Distinct Values


SELECT
    DISTINCT ContentType
FROM engagement_data
UPDATE dbo.engagement_data
SET ContentType = CASE
    WHEN LOWER(ContentType) = 'newsletter' THEN 'Newsletter'
    WHEN LOWER(ContentType) = 'video' THEN 'Video'
    WHEN LOWER(ContentType) = 'socialmedia' THEN 'SocialMedia'
END
WHERE ContentType != 'Blog'

--Likes Range

SELECT
    MIN(Likes) AS MinLikes,
    MAX(Likes) AS MaxLikes
FROM engagement_data

SELECT
    COUNT(*) AS ZeroLikes
FROM engagement_data
WHERE Likes = 0

--EngagementDate Range

SELECT 
    MIN(EngagementDate) AS Earliest_Date,
    MAX(EngagementDate) AS Latest_Date
FROM engagement_data

-- ProductID FK

SELECT  
    DISTINCT ProductID
FROM engagement_data
WHERE ProductID NOT IN (SELECT ProductID FROM products)

--ViewsClicksCombined — نشوف جوه إيه

SELECT
    DISTINCT ViewsClicksCombined
FROM engagement_data

ALTER TABLE dbo.engagement_data
ADD Views INT, Clicks INT

UPDATE dbo.engagement_data
SET 
    Views = CAST(LEFT(ViewsClicksCombined, CHARINDEX('-', ViewsClicksCombined) - 1) AS INT),
    Clicks = CAST(RIGHT(ViewsClicksCombined, LEN(ViewsClicksCombined) - CHARINDEX('-', ViewsClicksCombined)) AS INT)

SELECT 
   
    Views, 
    Clicks
FROM dbo.engagement_data

SELECT ContentType, COUNT(*) AS ZeroLikesCount
FROM dbo.engagement_data
WHERE Likes = 0
GROUP BY ContentType

SELECT DISTINCT ContentType
FROM dbo.engagement_data


ALTER TABLE dbo.engagement_data
DROP COLUMN ViewsClicksCombined


SELECT  *
	FROM geography

--GeographyID Duplicates
SELECT
    GeographyID,
    COUNT(*) AS Times_Repeated
FROM geography
GROUP BY GeographyID
HAVING COUNT(*) > 1

--Country Distinct + Spaces

SELECT 
    DISTINCT Country
FROM geography
ORDER BY Country

SELECT
    Country
FROM geography
WHERE LEN(Country) != LEN(TRIM(Country))

-- City Distinct + Spaces

SELECT DISTINCT City
FROM dbo.geography
ORDER BY City

SELECT City
FROM dbo.geography
WHERE LEN(City) != LEN(TRIM(City))
 

 SELECT
    SUM(Views) AS Total_Views,
    SUM(Clicks) AS Total_Clicks, 
    SUM(Likes) AS Total_Likes,
    SUM(Clicks + Likes) AS Total_Interactions,
    CAST(
        SUM(Clicks + Likes) * 100.0 / SUM(Views)
    AS DECIMAL(5,2)) AS Engagement_Rate
FROM dbo.engagement_data
WHERE ContentType != 'Newsletter'