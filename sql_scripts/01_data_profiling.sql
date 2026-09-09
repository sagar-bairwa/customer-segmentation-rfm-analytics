------------------------------------------ 01) Data Profiling -----------------------------------------------
--=======================================================================================================

USE E_Commerce;

-- =====================================================
-- 1. TABLE STRUCTURE
-- =====================================================

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'data'
ORDER BY ORDINAL_POSITION;




-- =====================================================
-- 2. DATASET SIZE
-- =====================================================

SELECT
    (SELECT COUNT(*) 
     FROM data) AS TotalRows,

    (SELECT COUNT(*)
     FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_NAME = 'data') AS TotalColumns;




-- =====================================================
-- 3. NULL / COMPLETENESS ANALYSIS
-- =====================================================

SELECT
    COUNT(*) AS TotalRows,

    COUNT(*) - COUNT(InvoiceNo) AS InvoiceNo_Null,
    COUNT(*) - COUNT(StockCode) AS StockCode_Null,
    COUNT(*) - COUNT(Description) AS Description_Null,
    COUNT(*) - COUNT(Quantity) AS Quantity_Null,
    COUNT(*) - COUNT(InvoiceDate) AS InvoiceDate_Null,
    COUNT(*) - COUNT(UnitPrice) AS UnitPrice_Null,
    COUNT(*) - COUNT(CustomerID) AS CustomerID_Null,
    COUNT(*) - COUNT(Country) AS Country_Null,

    CAST(100.0 * (COUNT(*) - COUNT(CustomerID))
         / COUNT(*) AS DECIMAL(5,2)) AS CustomerID_Null_Pct
FROM data;



-- Blank / whitespace descriptions

SELECT
    COUNT(*) AS BlankDescriptionRows
FROM data
WHERE Description IS NOT NULL
  AND LTRIM(RTRIM(Description)) = '';




-- =====================================================
-- 4. CARDINALITY / DISTINCT VALUES
-- =====================================================

SELECT
    COUNT(DISTINCT InvoiceNo) AS UniqueInvoices,
    COUNT(DISTINCT StockCode) AS UniqueProducts,
    COUNT(DISTINCT Description) AS UniqueDescriptions,
    COUNT(DISTINCT CustomerID) AS UniqueCustomers,
    COUNT(DISTINCT Country) AS UniqueCountries
FROM data;




-- =====================================================
-- 5. DATE PROFILING
-- =====================================================

SELECT
    MIN(InvoiceDate) AS FirstTransactionDate,
    MAX(InvoiceDate) AS LastTransactionDate,
    SUM(CASE
            WHEN InvoiceDate IS NULL THEN 1
            ELSE 0
        END) AS NullDates
FROM data;




-- =====================================================
-- 6. QUANTITY / TRANSACTION PROFILING
-- =====================================================

SELECT
    MIN(Quantity) AS MinimumQuantity,
    MAX(Quantity) AS MaximumQuantity,
    AVG(CAST(Quantity AS DECIMAL(18,2))) AS AverageQuantity,

    SUM(CASE WHEN Quantity > 0 THEN 1 ELSE 0 END)
        AS PositiveQuantityRows,

    SUM(CASE WHEN Quantity = 0 THEN 1 ELSE 0 END)
        AS ZeroQuantityRows,

    SUM(CASE WHEN Quantity < 0 THEN 1 ELSE 0 END)
        AS NegativeQuantityRows
FROM data;



-- Extreme negative quantity records

SELECT TOP 20
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CustomerID,
    Country
FROM data
WHERE Quantity < 0
ORDER BY Quantity ASC;



-- Transaction classification

SELECT
    CASE
        WHEN Quantity > 0 THEN 'Positive Sale'
        WHEN Quantity < 0 AND InvoiceNo LIKE 'C%'
            THEN 'Cancellation / Return'
        WHEN Quantity < 0 AND InvoiceNo NOT LIKE 'C%'
            THEN 'Negative Non-C Invoice'
        WHEN Quantity = 0 THEN 'Zero Quantity'
        ELSE 'Other'
    END AS TransactionType,

    COUNT(*) AS [RowCount]

FROM data

GROUP BY
    CASE
        WHEN Quantity > 0 THEN 'Positive Sale'
        WHEN Quantity < 0 AND InvoiceNo LIKE 'C%'
            THEN 'Cancellation / Return'
        WHEN Quantity < 0 AND InvoiceNo NOT LIKE 'C%'
            THEN 'Negative Non-C Invoice'
        WHEN Quantity = 0 THEN 'Zero Quantity'
        ELSE 'Other'
    END

ORDER BY [RowCount] DESC;




-- =====================================================
-- 7. UNIT PRICE PROFILING
-- =====================================================

SELECT
    MIN(UnitPrice) AS MinimumUnitPrice,
    MAX(UnitPrice) AS MaximumUnitPrice,
    AVG(CAST(UnitPrice AS DECIMAL(18,2))) AS AverageUnitPrice,

    SUM(CASE WHEN UnitPrice IS NULL THEN 1 ELSE 0 END)
        AS NullUnitPrice,

    SUM(CASE WHEN UnitPrice = 0 THEN 1 ELSE 0 END)
        AS ZeroUnitPrice,

    SUM(CASE WHEN UnitPrice < 0 THEN 1 ELSE 0 END)
        AS NegativeUnitPrice,

    SUM(CASE WHEN UnitPrice > 0 THEN 1 ELSE 0 END)
        AS PositiveUnitPrice

FROM data;



-- Positive quantity with zero price

SELECT
    COUNT(*) AS PositiveSalesWithZeroPrice
FROM data
WHERE Quantity > 0
  AND UnitPrice = 0;



-- Negative quantity with zero price

SELECT
    COUNT(*) AS NegativeQuantityWithZeroPrice
FROM data
WHERE Quantity < 0
  AND UnitPrice = 0;




-- =====================================================
-- 8. CUSTOMER ATTRIBUTION PROFILING
-- =====================================================

SELECT
    CASE
        WHEN CustomerID IS NULL THEN 'Missing CustomerID'
        ELSE 'Valid CustomerID'
    END AS CustomerStatus,
    COUNT(*) AS [RowCount],
    CAST(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER()
        AS DECIMAL(5,2)
    ) AS RowPercentage
FROM data
GROUP BY
    CASE
        WHEN CustomerID IS NULL THEN 'Missing CustomerID'
        ELSE 'Valid CustomerID'
    END;




-- =====================================================
-- 9. DUPLICATE ANALYSIS
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
FROM data
GROUP BY
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CustomerID,
    Country
HAVING COUNT(*) > 1
ORDER BY DuplicateCount DESC;




-- =====================================================
-- 10. TRANSACTION VALUE PROFILING
-- =====================================================

SELECT
    MIN(Quantity * UnitPrice) AS MinimumTransactionValue,
    MAX(Quantity * UnitPrice) AS MaximumTransactionValue,
    AVG(CAST(Quantity * UnitPrice AS DECIMAL(18,2)))
        AS AverageTransactionValue
FROM data
WHERE Quantity > 0
  AND UnitPrice > 0;


-- Top transaction values

SELECT TOP 20
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    UnitPrice,
    Quantity * UnitPrice AS TotalAmount,
    CustomerID
FROM data
WHERE Quantity > 0
  AND UnitPrice > 0
ORDER BY TotalAmount DESC;