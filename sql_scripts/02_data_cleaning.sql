
------------------------------------------------02) DATA CLEANING -----------------------------------------------------
--=====================================================================================================================

USE E_Commerce;


-- =====================================================
-- 1. CREATE CLEANING TABLE
-- =====================================================


-- Remove previous derived tables when rerunning the script

IF OBJECT_ID('sales_cleaned', 'U') IS NOT NULL
    DROP TABLE sales_cleaned;


SELECT *
INTO sales_cleaned 
FROM data;



-- =====================================================
-- 2. REMOVE EXACT DUPLICATE RECORDS
-- =====================================================

SELECT
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CustomerID,
    Country,
    COUNT(*) AS DuplicateCount
FROM sales_cleaned
GROUP BY
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CustomerID,
    Country
HAVING COUNT(*) > 1;


-- Remove exact duplicate records while keeping one copy

WITH DuplicateRecords AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY
                InvoiceNo,
                StockCode,
                Description,
                Quantity,
                InvoiceDate,
                UnitPrice,
                CustomerID,
                Country
            ORDER BY (SELECT NULL)
        ) AS RowNum
    FROM sales_cleaned
)
DELETE FROM DuplicateRecords
WHERE RowNum > 1;




-- =====================================================
-- 3. CUSTOMER ID HANDLING
-- =====================================================

-- CustomerID is required for customer-level RFM analysis.
-- Transactions with NULL CustomerID are retained in
-- sales_cleaned but excluded from the RFM sales dataset.




-- =====================================================
-- 4. QUANTITY / TRANSACTION HANDLING
-- =====================================================

-- Positive Quantity represents sales.
-- Negative Quantity represents returns, cancellations,
-- or other adjustment transactions.
-- Zero Quantity does not represent a valid sale.
--
-- Only positive-quantity transactions will be included
-- in the RFM sales dataset.




-- =====================================================
-- 5. UNIT PRICE HANDLING
-- =====================================================

-- UnitPrice must be greater than zero for a valid
-- revenue-generating RFM transaction.
--
-- NULL and non-positive UnitPrice records are excluded
-- from the RFM sales dataset.




-- =====================================================
-- 6. CREATE RFM-READY SALES DATASET
-- =====================================================

-- RFM requires customer-attributable, revenue-generating
-- sales transactions.
--
-- Therefore:
--   CustomerID IS NOT NULL
--   Quantity > 0
--   UnitPrice > 0
--
-- TotalAmount = Quantity × UnitPrice


IF OBJECT_ID('rfm_sales', 'U') IS NOT NULL
    DROP TABLE rfm_sales;


SELECT
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CustomerID,
    Country,
    Quantity * UnitPrice AS TotalAmount
INTO rfm_sales                          
FROM sales_cleaned
WHERE CustomerID IS NOT NULL
  AND Quantity > 0
  AND UnitPrice > 0;





