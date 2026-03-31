/*
========================================================================
Script Name: 02_risk_segmentation.sql
Description: Creates a customer risk profile view dividing customers
             into High, Medium, and Low risk segments. 
             Calculates the distribution across these segments.
========================================================================
*/

-- Create a VIEW called customer_risk_profile
CREATE OR REPLACE VIEW customer_risk_profile AS
SELECT 
    id,
    monthly_income, 
    debt_ratio, 
    age,
    CASE
        WHEN serious_dlqin2yrs = 1 OR number_of_times90_days_late >= 2 THEN 'High Risk'
        WHEN revolving_utilization_of_unsecured_lines > 0.5 OR number_of_time30_59_days_past_due_not_worse >= 2 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_segment
FROM customers;

-- Query showing count and percentage of customers in each risk segment
WITH segment_counts AS (
    SELECT 
        risk_segment, 
        COUNT(*) AS segment_count
    FROM customer_risk_profile
    GROUP BY risk_segment
),
total_count AS (
    SELECT COUNT(*) AS total FROM customer_risk_profile
)
SELECT 
    s.risk_segment,
    s.segment_count,
    ROUND((s.segment_count * 100.0) / t.total, 2) AS percentage
FROM segment_counts s
CROSS JOIN total_count t
ORDER BY s.segment_count DESC;
