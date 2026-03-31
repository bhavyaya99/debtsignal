/*
========================================================================
Script Name: 04_dti_analysis.sql
Description: Categorizes customers into Low, Moderate, and High DTI 
             (Debt-to-Income) buckets and computes the default rate.
========================================================================
*/

-- 1 & 2 & 3. DTI Bucketing using a CTE named dti_buckets
WITH dti_buckets AS (
    SELECT 
        id,
        serious_dlqin2yrs,
        debt_ratio,
        CASE
            WHEN debt_ratio < 0.3 THEN 'Low'
            WHEN debt_ratio >= 0.3 AND debt_ratio <= 0.6 THEN 'Moderate'
            WHEN debt_ratio > 0.6 THEN 'High'
            ELSE 'Unknown'
        END AS dti_category
    FROM customers
)
SELECT 
    dti_category,
    COUNT(*) AS total_customers,
    AVG(serious_dlqin2yrs) AS avg_default_rate
FROM dti_buckets
GROUP BY dti_category
ORDER BY 
    CASE dti_category
        WHEN 'High' THEN 1
        WHEN 'Moderate' THEN 2
        WHEN 'Low' THEN 3
        ELSE 4
    END;
