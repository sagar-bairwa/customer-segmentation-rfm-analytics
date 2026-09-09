------------------------------------------------03) DATA VALIDATION ---------------------------------------------------
--=====================================================================================================================


USE E_Commerce;


-- =====================================================
-- 1. ROW COUNT RECONCILIATION
-- =====================================================

SELECT
    (SELECT COUNT(*) FROM data) AS RawRows,
    (SELECT COUNT(*) FROM sales_cleaned) AS CleanedRows,
    (SELECT COUNT(*) FROM rfm_sales) AS RFMSalesRows;




-- =====================================================
-- 2. DUPLICATE VALIDATION
-- =====================================================

SELECT
    COUNT(*) AS RemainingDuplicateGroups
FROM
(
    SELECT
        InvoiceNo,
        StockCode,
        Description,
        Quantity,
        InvoiceDate,
        UnitPrice,
        CustomerID,
        Country
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
    HAVING COUNT(*) > 1
) AS Duplicates;





-- =====================================================
-- 2. DUPLICATE VALIDATION
-- =====================================================

SELECT
    COUNT(*) AS RemainingDuplicateGroups
FROM
(
    SELECT
        InvoiceNo,
        StockCode,
        Description,
        Quantity,
        InvoiceDate,
        UnitPrice,
        CustomerID,
        Country
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
    HAVING COUNT(*) > 1
) AS Duplicates;





-- =====================================================
-- 3. CUSTOMER ID VALIDATION
-- =====================================================

SELECT
    COUNT(*) AS InvalidCustomerIDRows
FROM rfm_sales
WHERE CustomerID IS NULL;





-- =====================================================
-- 4. QUANTITY VALIDATION
-- =====================================================

SELECT
    COUNT(*) AS InvalidQuantityRows
FROM rfm_sales
WHERE Quantity <= 0;




-- =====================================================
-- 5. UNIT PRICE VALIDATION
-- =====================================================

SELECT
    COUNT(*) AS InvalidUnitPriceRows
FROM rfm_sales
WHERE UnitPrice IS NULL
   OR UnitPrice <= 0;




-- =====================================================
-- 6. TOTAL AMOUNT VALIDATION
-- =====================================================

SELECT
    COUNT(*) AS InvalidTotalAmountRows
FROM rfm_sales
WHERE TotalAmount IS NULL
   OR TotalAmount <= 0;


SELECT
    COUNT(*) AS IncorrectTotalAmountRows
FROM rfm_sales
WHERE TotalAmount <> Quantity * UnitPrice;





-- =====================================================
-- 7. FINAL RFM DATASET SUMMARY
-- =====================================================

SELECT
    COUNT(*) AS TotalSalesRows,
    COUNT(DISTINCT InvoiceNo) AS UniqueInvoices,
    COUNT(DISTINCT CustomerID) AS UniqueCustomers,
    COUNT(DISTINCT StockCode) AS UniqueProducts,
    COUNT(DISTINCT Country) AS UniqueCountries,
    SUM(TotalAmount) AS TotalRevenue,
    MIN(InvoiceDate) AS FirstTransactionDate,
    MAX(InvoiceDate) AS LastTransactionDate
FROM rfm_sales;


