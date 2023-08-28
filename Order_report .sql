USE customers;

SHOW columns
FROM  sc_customertable;


-- UPDATE THE ORDER DATE  COLUMN IN OUR ORDER TABLE TO DATETIME FOR BETTER READABILITY
UPDATE sc_order 
SET Order_Date = (SELECT str_to_date(Order_Date, '%m/%d/%y'));

 
ALTER TABLE sc_order
DROP COLUMN order_prod_name;


-- Customer Insights:
-- Which customers have made the most frequent and highest total value orders?
SELECT 
	Order_Customer_Id
    , COUNT(Order_Id) AS Total_order_count
    ,SUM(Order_Item_Total) AS Total_order_value
FROM sc_order
GROUP BY Order_Customer_Id
ORDER BY Total_order_count DESC,Total_order_value DESC;

-- How has the average order quantity and total spend changed over time for different regions or countries?
SELECT 
	Order_Country
    ,EXTRACT(YEAR FROM Order_Date) AS YEAR
    ,COUNT(Order_Id) AS Total_order
FROM sc_order
GROUP BY Order_Country, EXTRACT(YEAR FROM Order_Date)
ORDER BY Order_Country, Total_order DESC, YEAR;
    
SELECT 
	Order_Region
    ,EXTRACT(YEAR FROM Order_Date) AS YEAR
    ,SUM(Order_Item_Total) AS Total_order
FROM sc_order
GROUP BY Order_Region, EXTRACT(YEAR FROM Order_Date)
ORDER BY Order_Region, Total_order DESC, YEAR;

-- Product Analysis:
-- What are the top-selling products in terms of quantity and revenue?
SELECT 
	Order_Product_Id
    ,COUNT(*) AS Total_Order_Count
FROM sc_order
GROUP BY Order_Product_Id
ORDER BY Total_Order_Count DESC;

SELECT 
	Order_Product_Id
    ,SUM(Order_Item_Total) AS Total_Product_Revenue
FROM sc_order
GROUP BY Order_Product_Id
ORDER BY Total_Product_Revenue DESC;

-- Can we detect any trends in product performance, such as seasonality or changes in demand, over specific time periods?
SELECT 
	Order_Product_Id,
    SUM(CASE WHEN MONTH(Order_Date) IN (12, 1, 2) THEN 1 ELSE 0 END) AS Winter_order_count,
    SUM(CASE WHEN MONTH(Order_Date) IN (3, 4, 5) THEN 1 ELSE 0 END) AS Spring_order_count,
    SUM(CASE WHEN MONTH(Order_Date) IN (6, 7, 8) THEN 1 ELSE 0 END) AS Summer_order_count,
    SUM(CASE WHEN MONTH(Order_Date) IN (9, 10, 11) THEN 1 ELSE 0 END) AS Fall_order_count,
    COUNT(*) As Total_order_count
FROM sc_order
GROUP BY Order_Product_Id;

-- Regional and International Performance:

-- Which countries contribute the most to the overall revenue and profit? Are there any emerging markets?
SELECT
	Order_Country
    , SUM(Order_Item_Total) AS Total_revenue
FROM sc_order
GROUP BY Order_Country
ORDER BY Total_revenue DESC;

SELECT
	Order_Country
    , SUM(Order_Profit_Per_Order) AS Total_Profit
FROM sc_order
GROUP BY Order_Country
ORDER BY Total_Profit DESC;

-- Are there any regions or countries with unusually high order cancellation rates, and what might be causing this?
WITH Cancelation_rate AS 
(SELECT 
	Order_Country
    ,COUNT(Order_Id) AS Total_Order
    ,COUNT(CASE WHEN Order_Status LIKE '%CANCELED%' THEN 1 ELSE NULL END) AS Total_Order_Canceled
FROM sc_order
GROUP BY Order_Country
ORDER BY Total_Order_Canceled DESC
)

SELECT 
	Order_country
    ,Total_Order
    ,Total_Order_Canceled
    ,ROUND(((Total_Order_Canceled/Total_Order)*100), 2) AS Cancelation_Percentage
FROM Cancelation_rate
;



-- Find the best year according to revenue generated
SELECT
	YEAR(Order_Date) AS Year
    , SUM(Order_Item_Total) AS Total_Revenue
FROM sc_order
GROUP BY YEAR(Order_Date)
ORDER BY Total_Revenue DESC;
	
-- Find the best selling product for each year
WITH best_product AS (
SELECT
	YEAR(Order_Date) AS Year
    ,Order_Product_id
    ,SUM(Order_Item_Total) AS Best_Selling_Product
FROM sc_order
GROUP BY YEAR(Order_Date), Order_Product_id

)

SELECT 
	 Year
     ,Order_Product_id
     ,Best_Selling_Product
FROM best_product
WHERE (Year, Best_Selling_Product) IN (select year, MAX(Best_Selling_Product) AS Best_Selling_Product FROM best_product GROUP BY Year)
ORDER BY YEAR;
	
;


SELECT * FROM sc_order
LIMIT 1000;

SELECT DISTINCT Order_status
FROM sc_order;

