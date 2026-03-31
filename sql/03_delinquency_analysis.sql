/*
========================================================================
Script Name: 03_delinquency_analysis.sql
Description: Analyzes delinquency rates by age groups, identifies top 
             late payers, and compares default rates by median income.
========================================================================
*/

-- 1. Average delinquency rate by age group using CASE WHEN
SELECT 
    CASE 
        WHEN age BETWEEN 20 AND 30 THEN '20-30'
        WHEN age BETWEEN 31 AND 40 THEN '31-40'
        WHEN age BETWEEN 41 AND 50 THEN '41-50'
        WHEN age BETWEEN 51 AND 60 THEN '51-60'
        WHEN age > 60 THEN '60+'
        ELSE 'Unknown'
    END AS age_group,
    AVG(serious_dlqin2yrs) AS avg_delinquency_rate
FROM customers
GROUP BY age_group
ORDER BY age_group;

-- 2. Top 10 customers with highest number of total late payments
SELECT 
    id,
    (number_of_time30_59_days_past_due_not_worse + number_of_time60_89_days_past_due_not_worse + number_of_times90_days_late) AS total_late_payments,
    number_of_time30_59_days_past_due_not_worse,
    number_of_time60_89_days_past_due_not_worse,
    number_of_times90_days_late
FROM customers
ORDER BY total_late_payments DESC
LIMIT 10;

-- 3. Delinquency rate for customers with monthly_income above vs below median income
WITH median_calc AS (
    SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY monthly_income) AS median_income
    FROM customers
)
SELECT 
    CASE 
        WHEN monthly_income > m.median_income THEN 'Above Median'
        ELSE 'Below or Equal to Median'
    END AS income_group,
    AVG(serious_dlqin2yrs) AS avg_delinquency_rate
FROM customers
CROSS JOIN median_calc m
GROUP BY income_group;
