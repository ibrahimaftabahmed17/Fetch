WITH eligible_users AS (
    SELECT 
        ID AS USER_ID
    FROM users
    WHERE CREATED_DATE <= DATE('now', '-6 months')
),
txns_with_brand AS (
    SELECT 
        t.BARCODE,
        t.FINAL_SALE
    FROM txns_deduped t
    INNER JOIN eligible_users u
        ON t.USER_ID = u.USER_ID
),
sales_by_brand AS (
    SELECT 
        p.BRAND,
        SUM(COALESCE(t.FINAL_SALE, 0)) AS TOTAL_SALES
    FROM txns_with_brand t
    INNER JOIN products_cleaned  p
        ON t.BARCODE = p.BARCODE
    GROUP BY p.BRAND
)
SELECT 
    BRAND,
    TOTAL_SALES
FROM sales_by_brand
ORDER BY TOTAL_SALES DESC
LIMIT 5;
---------------------------------------------------

SELECT 
    USER_ID,
    COUNT(*) AS num_transactions
FROM txns_deduped
GROUP BY USER_ID
ORDER BY num_transactions DESC
LIMIT 4;

---------------------------------------------------

WITH filtered_txns AS (
    SELECT 
        t.RECEIPT_ID,
        t.FINAL_SALE,
        p.BRAND
    FROM txns_deduped t
    INNER JOIN products_cleaned p
        ON t.BARCODE = p.BARCODE
    WHERE p.CATEGORY_2 = 'Dips & Salsa'
),
brand_stats AS (
    SELECT 
        BRAND,
        COUNT(DISTINCT RECEIPT_ID) AS num_receipts,
        SUM(CASE WHEN FINAL_SALE IS NOT NULL THEN FINAL_SALE ELSE 0 END) AS total_sales
    FROM filtered_txns
    GROUP BY BRAND
)
SELECT 
    BRAND,
    num_receipts,
    total_sales
FROM brand_stats
ORDER BY num_receipts DESC, total_sales DESC
LIMIT 1;
---------------------------------------------------



