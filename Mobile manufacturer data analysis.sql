--SQL Advance Case Study


--Q1--BEGIN 

SELECT DISTINCT l.State
FROM Fact_Transactions f
JOIN Dim_Location l
    ON f.IDLocation = l.IDLocation
WHERE f.Date >= '2005-01-01'

--Q1--END

--Q2--BEGIN

SELECT TOP 1
       l.State,
       SUM(f.Quantity) AS Total_Quantity
FROM Fact_Transactions f
JOIN Dim_Model m
    ON f.IDModel = m.IDModel
JOIN Dim_Manufacturer mf
    ON m.IDManufacturer = mf.IDManufacturer
JOIN Dim_Location l
    ON f.IDLocation = l.IDLocation
WHERE mf.Manufacturer_Name = 'Samsung'
  AND l.Country = 'US'
GROUP BY l.State
ORDER BY Total_Quantity DESC

--Q2--END

--Q3--BEGIN      

SELECT m.Model_Name,
       l.ZipCode,
       l.State,
       COUNT(*) AS No_Of_Transactions
FROM Fact_Transactions f
JOIN Dim_Model m
    ON f.IDModel = m.IDModel
JOIN Dim_Location l
    ON f.IDLocation = l.IDLocation
GROUP BY m.Model_Name, l.ZipCode, l.State

--Q3--END

--Q4--BEGIN

SELECT TOP 1
       Model_Name,
       Unit_Price
FROM Dim_Model
ORDER BY Unit_Price ASC

--Q4--END

--Q5--BEGIN

WITH TopManufacturers AS (
    SELECT TOP 5
           m.IDManufacturer
    FROM Fact_Transactions f
    JOIN Dim_Model m
        ON f.IDModel = m.IDModel
    GROUP BY m.IDManufacturer
    ORDER BY SUM(f.Quantity) DESC
)
SELECT mo.Model_Name,
       AVG(CAST(mo.Unit_Price AS DECIMAL(10,2))) AS Avg_Price
FROM Dim_Model mo
JOIN TopManufacturers tm
    ON mo.IDManufacturer = tm.IDManufacturer
GROUP BY mo.Model_Name
ORDER BY Avg_Price

--Q5--END

--Q6--BEGIN

SELECT c.Customer_Name,
       AVG(f.TotalPrice) AS Avg_Amount_Spent
FROM Fact_Transactions f
JOIN Dim_Customer c
    ON f.IDCustomer = c.IDCustomer
WHERE YEAR(f.Date) = 2009
GROUP BY c.Customer_Name
HAVING AVG(f.TotalPrice) > 500

--Q6--END
	
--Q7--BEGIN  
	
WITH YearlyTopModels AS (
    SELECT YEAR(f.Date) AS Sales_Year,
           f.IDModel,
           SUM(f.Quantity) AS Total_Quantity,
           DENSE_RANK() OVER (
               PARTITION BY YEAR(f.Date)
               ORDER BY SUM(f.Quantity) DESC
           ) AS Rnk
    FROM Fact_Transactions f
    WHERE YEAR(f.Date) IN (2008, 2009, 2010)
    GROUP BY YEAR(f.Date), f.IDModel
)
SELECT m.Model_Name
FROM YearlyTopModels y
JOIN Dim_Model m
    ON y.IDModel = m.IDModel
WHERE y.Rnk <= 5
GROUP BY m.Model_Name
HAVING COUNT(DISTINCT y.Sales_Year) = 3	

--Q7--END	
--Q8--BEGIN

WITH YearlySales AS (
    SELECT YEAR(f.Date) AS Sales_Year,
           mf.Manufacturer_Name,
           SUM(f.TotalPrice) AS Total_Sales,
           DENSE_RANK() OVER (
               PARTITION BY YEAR(f.Date)
               ORDER BY SUM(f.TotalPrice) DESC
           ) AS Rnk
    FROM Fact_Transactions f
    JOIN Dim_Model m
        ON f.IDModel = m.IDModel
    JOIN Dim_Manufacturer mf
        ON m.IDManufacturer = mf.IDManufacturer
    WHERE YEAR(f.Date) IN (2009, 2010)
    GROUP BY YEAR(f.Date), mf.Manufacturer_Name
)
SELECT Sales_Year,
       Manufacturer_Name,
       Total_Sales
FROM YearlySales
WHERE Rnk = 2

--Q8--END
--Q9--BEGIN
	
SELECT DISTINCT mf.Manufacturer_Name
FROM Fact_Transactions f
JOIN Dim_Model m
    ON f.IDModel = m.IDModel
JOIN Dim_Manufacturer mf
    ON m.IDManufacturer = mf.IDManufacturer
WHERE YEAR(f.Date) = 2010
AND mf.Manufacturer_Name NOT IN (
    SELECT DISTINCT mf2.Manufacturer_Name
    FROM Fact_Transactions f2
    JOIN Dim_Model m2
        ON f2.IDModel = m2.IDModel
    JOIN Dim_Manufacturer mf2
        ON m2.IDManufacturer = mf2.IDManufacturer
    WHERE YEAR(f2.Date) = 2009
)

--Q9--END

--Q10--BEGIN
	
WITH CustomerYearly AS (
    SELECT c.IDCustomer,
           c.Customer_Name,
           YEAR(f.Date) AS Sales_Year,
           AVG(CAST(f.TotalPrice AS DECIMAL(12,2))) AS Avg_Spend,
           AVG(CAST(f.Quantity AS DECIMAL(12,2))) AS Avg_Quantity
    FROM Fact_Transactions f
    JOIN Dim_Customer c
        ON f.IDCustomer = c.IDCustomer
    GROUP BY c.IDCustomer, c.Customer_Name, YEAR(f.Date)
),
TopCustomers AS (
    SELECT TOP 100
           IDCustomer
    FROM Fact_Transactions
    GROUP BY IDCustomer
    ORDER BY SUM(TotalPrice) DESC
)
SELECT cy.Customer_Name,
       cy.Sales_Year,
       cy.Avg_Spend,
       cy.Avg_Quantity,
       LAG(cy.Avg_Spend) OVER (
           PARTITION BY cy.IDCustomer
           ORDER BY cy.Sales_Year
       ) AS Prev_Year_Spend,
       CASE
           WHEN LAG(cy.Avg_Spend) OVER (
                    PARTITION BY cy.IDCustomer
                    ORDER BY cy.Sales_Year
                ) IS NULL THEN NULL
           ELSE
               ((cy.Avg_Spend -
                 LAG(cy.Avg_Spend) OVER (
                     PARTITION BY cy.IDCustomer
                     ORDER BY cy.Sales_Year
                 )) * 100.0 /
                 LAG(cy.Avg_Spend) OVER (
                     PARTITION BY cy.IDCustomer
                     ORDER BY cy.Sales_Year
                 ))
       END AS Spend_Percentage_Change
FROM CustomerYearly cy
JOIN TopCustomers tc
    ON cy.IDCustomer = tc.IDCustomer

--Q10--END
	