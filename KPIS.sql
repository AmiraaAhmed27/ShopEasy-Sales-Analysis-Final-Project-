
--Conversion Rate

SELECT 
    COUNT(CASE WHEN Action = 'Purchase' THEN 1 END) AS Total_Purchases,
    COUNT(CASE WHEN Action = 'View' THEN 1 END) AS Total_Visitors,
    CAST(
        COUNT(CASE WHEN Action = 'Purchase' THEN 1 END) * 100.0 / 
        COUNT(CASE WHEN Action = 'View' THEN 1 END)
    AS DECIMAL(5,2)) AS Conversion_Rate
FROM dbo.customer_journey

CREATE VIEW vw_ConversionRate AS
SELECT 
    COUNT(CASE WHEN Action = 'Purchase' THEN 1 END) AS Total_Purchases,
    COUNT(CASE WHEN Action = 'View' THEN 1 END) AS Total_Visitors,
    CAST(
        COUNT(CASE WHEN Action = 'Purchase' THEN 1 END) * 100.0 /
        NULLIF(COUNT(CASE WHEN Action = 'View' THEN 1 END), 0)
    AS DECIMAL(5,2)) AS Conversion_Rate
FROM dbo.customer_journey;
GO






--Customer Engagement Rate



 SELECT
    SUM(Views) AS Total_Views,
    SUM(Click) AS Total_Clicks,
    SUM(Likes) AS Total_Likes,
    SUM(Clicks + Likes) AS Total_Interactions,
    CAST(
        SUM(Clicks + Likes) * 100.0 / SUM(Views)
    AS DECIMAL(5,2)) AS Engagement_Rate
FROM dbo.engagement_data
WHERE ContentType != 'Newsletter'

CREATE VIEW vw_EngagementRate AS
SELECT
    SUM(Views) AS Total_Views,
    SUM(Clicks) AS Total_Clicks,
    SUM(Likes) AS Total_Likes,
    SUM(Clicks + Likes) AS Total_Interactions,
    CAST(
        SUM(Clicks + Likes) * 100.0 / NULLIF(SUM(Views), 0)
    AS DECIMAL(5,2)) AS Engagement_Rate
FROM dbo.engagement_data
WHERE ContentType != 'Newsletter';
GO
 








-- Average Order Value
SELECT 
    COUNT(DISTINCT cj.CustomerID) AS Total_Customers,
    SUM(p.Price) AS Total_Revenue,
    CAST(SUM(p.Price) * 1.0 / COUNT(DISTINCT cj.CustomerID) 
        AS DECIMAL(10,2)) AS AOV
FROM dbo.customer_journey cj
JOIN dbo.products p ON cj.ProductID = p.ProductID
WHERE cj.Action = 'Purchase'


CREATE VIEW vw_AverageOrderValue AS
SELECT 
    COUNT(DISTINCT cj.CustomerID) AS Total_Customers,
    SUM(p.Price) AS Total_Revenue,
    CAST(
        SUM(p.Price) * 1.0 / NULLIF(COUNT(DISTINCT cj.CustomerID), 0)
    AS DECIMAL(10,2)) AS AOV
FROM dbo.customer_journey cj
JOIN dbo.products p ON cj.ProductID = p.ProductID
WHERE cj.Action = 'Purchase';
GO



--Customer Feedback Score

SELECT
    COUNT(ReviewID) AS Total_Reviews,
    CAST(AVG(CAST(Rating AS DECIMAL(5,2))) AS DECIMAL(5,2)) AS Avg_Rating,
    COUNT(CASE WHEN Rating >= 4 THEN 1 END) AS Positive_Reviews,
    COUNT(CASE WHEN Rating = 3 THEN 1 END) AS Neutral_Reviews,
    COUNT(CASE WHEN Rating <= 2 THEN 1 END) AS Negative_Reviews
FROM dbo.customer_reviews



SELECT
    SUM(p.Price) AS Total_Revenue,
    COUNT(CASE WHEN cj.Action = 'Purchase' THEN 1 END) AS Total_Purchases,
    CAST(SUM(p.Price) * 1.0 / 
        NULLIF(COUNT(CASE WHEN cj.Action = 'Purchase' THEN 1 END), 0)
    AS DECIMAL(10,2)) AS Revenue_Per_Purchase
FROM dbo.customer_journey cj
JOIN dbo.products p ON cj.ProductID = p.ProductID
WHERE cj.Action = 'Purchase'







-- 4) Customer Feedback Score
CREATE VIEW vw_CustomerFeedbackScore AS
SELECT
    COUNT(ReviewID) AS Total_Reviews,
    CAST(AVG(CAST(Rating AS DECIMAL(5,2))) AS DECIMAL(5,2)) AS Avg_Rating,
    COUNT(CASE WHEN Rating >= 4 THEN 1 END) AS Positive_Reviews,
    COUNT(CASE WHEN Rating = 3 THEN 1 END) AS Neutral_Reviews,
    COUNT(CASE WHEN Rating <= 2 THEN 1 END) AS Negative_Reviews
FROM dbo.customer_reviews;
GO
 
-- 5) Revenue Per Purchase
CREATE VIEW vw_RevenuePerPurchase AS
SELECT
    SUM(p.Price) AS Total_Revenue,
    COUNT(CASE WHEN cj.Action = 'Purchase' THEN 1 END) AS Total_Purchases,
    CAST(
        SUM(p.Price) * 1.0 / 
        NULLIF(COUNT(CASE WHEN cj.Action = 'Purchase' THEN 1 END), 0)
    AS DECIMAL(10,2)) AS Revenue_Per_Purchase
FROM dbo.customer_journey cj
JOIN dbo.products p ON cj.ProductID = p.ProductID
WHERE cj.Action = 'Purchase';
GO




CREATE VIEW vw_DropOffAnalysis AS
SELECT
    Stage,
    COUNT(*) AS DropOff_Count
FROM customer_journey
WHERE Action='Drop-off'
GROUP BY Stage;

CREATE VIEW vw_FunnelAnalysis
AS
SELECT
    Action,
    COUNT(*) AS Total_Count
FROM dbo.customer_journey
GROUP BY Action





SELECT * FROM dbo.vw_ConversionRate;
SELECT * FROM dbo.vw_EngagementRate;
SELECT * FROM dbo.vw_AverageOrderValue;
SELECT * FROM dbo.vw_CustomerFeedbackScore;
SELECT * FROM dbo.vw_RevenuePerPurchase;
SELECT * FROM dbo.vw_DropOffAnalysis;
SELECT * FROM dbo.vw_FunnelAnalysis;



CREATE VIEW vw_product_engagement AS
SELECT
    p.ProductName,
    SUM(e.Views) AS TotalViews,
    SUM(e.Clicks) AS TotalClicks,
    SUM(e.Likes) AS TotalLikes,
    SUM(e.Views + e.Clicks + e.Likes) AS EngagementScore
FROM engagement_data e
JOIN products p
    ON e.ProductID = p.ProductID
GROUP BY p.ProductName;


CREATE VIEW vw_product_ctr AS
SELECT
    p.ProductName,
    SUM(e.Views) AS TotalViews,
    SUM(e.Clicks) AS TotalClicks,
    ROUND(
        100.0 * SUM(e.Clicks) / NULLIF(SUM(e.Views),0),
        2
    ) AS CTR_Percentage
FROM engagement_data e
JOIN products p
    ON e.ProductID = p.ProductID
GROUP BY p.ProductName;

CREATE VIEW vw_revenue_over_time AS
SELECT
    CAST(cj.VisitDate AS DATE) AS RevenueDate,
    SUM(p.Price) AS Revenue
FROM customer_journey cj
JOIN products p
    ON cj.ProductID = p.ProductID
WHERE cj.Action = 'Purchase'
GROUP BY CAST(cj.VisitDate AS DATE);


CREATE VIEW vw_monthly_revenue AS
SELECT
    FORMAT(cj.VisitDate,'yyyy-MM') AS RevenueMonth,
    SUM(p.Price) AS Revenue
FROM customer_journey cj
JOIN products p
    ON cj.ProductID = p.ProductID
WHERE cj.Action = 'Purchase'
GROUP BY FORMAT(cj.VisitDate,'yyyy-MM');


CREATE VIEW vw_satisfaction_summary AS
SELECT
    CASE 
        WHEN Rating >= 4 THEN 'Positive (4-5)'
        WHEN Rating = 3 THEN 'Neutral (3)'
        WHEN Rating <= 2 THEN 'Negative (1-2)'
    END AS Satisfaction_Category,
    COUNT(*) AS Reviews_Count
FROM customer_reviews
GROUP BY 
    CASE 
        WHEN Rating >= 4 THEN 'Positive (4-5)'
        WHEN Rating = 3 THEN 'Neutral (3)'
        WHEN Rating <= 2 THEN 'Negative (1-2)'
    END;



    CREATE VIEW vw_rating_trend AS
SELECT
    YEAR(ReviewDate) AS ReviewYear,
    AVG(Rating) AS Avg_Rating
FROM customer_reviews
WHERE ReviewDate IS NOT NULL
GROUP BY YEAR(ReviewDate)


CREATE VIEW vw_reviews_monthly
AS
SELECT 
    ReviewID,
    ReviewDate,

    -- شكل الشهر للعرض في Power BI
    LEFT(DATENAME(MONTH, ReviewDate), 3) + ' ' + CAST(YEAR(ReviewDate) AS VARCHAR(4)) AS ReviewMonth,

    -- عمود للـ sorting (مهم جدًا عشان الترتيب مايبقاش غلط)
    YEAR(ReviewDate) * 100 + MONTH(ReviewDate) AS ReviewMonthSort

FROM customer_reviews;



CREATE VIEW vvw_age_distribution AS
WITH AgeCalc AS (
    SELECT
        CustomerID,
        Age,
        CASE
            WHEN Age BETWEEN 18 AND 25 THEN '18-25'
            WHEN Age BETWEEN 26 AND 35 THEN '26-35'
            WHEN Age BETWEEN 36 AND 50 THEN '36-50'
            WHEN Age BETWEEN 51 AND 69 THEN '51-69'
            ELSE 'Unknown'
        END AS AgeGroup
    FROM dbo.customers
)

SELECT 
    AgeGroup,
    COUNT(CustomerID) AS CustomerCount,
    
    CAST(
        COUNT(CustomerID) * 100.0 / (SELECT COUNT(*) FROM dbo.customers)
        AS INT
    ) AS Percentage

FROM AgeCalc
GROUP BY AgeGroup;




CREATE VIEW vw_product_ratings AS
SELECT 
    p.ProductID,
    p.ProductName,
    p.Category,
    COUNT(r.ReviewID) AS total_reviews,
    ROUND(AVG(CAST(r.Rating AS FLOAT)), 2) AS avg_rating
FROM products p
LEFT JOIN customer_reviews r
    ON p.ProductID = r.ProductID
GROUP BY 
    p.ProductID,
    p.ProductName,
    p.Category;











CREATE VIEW vw_low_rated_products AS
SELECT 
    p.ProductID,
    p.ProductName,
    p.Category,
    COUNT(r.ReviewID) AS total_reviews,
    ROUND(AVG(CAST(r.Rating AS FLOAT)), 2) AS avg_rating
FROM products p
LEFT JOIN customer_reviews r
    ON p.ProductID = r.ProductID
GROUP BY 
    p.ProductID,
    p.ProductName,
    p.Category
HAVING AVG(CAST(r.Rating AS FLOAT)) < 3;
































CREATE VIEW vw_Engagement_NoNewsletter AS
SELECT *
FROM dbo.engagement_data
WHERE ContentType != 'Newsletter'






