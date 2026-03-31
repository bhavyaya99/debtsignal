/*
========================================================================
Script Name: 05_cohort_analysis.sql
Description: Cohort analysis on customers using Window Functions, 
             ranking customers by debt within age cohorts, computing 
             cumulative defaults, and identifying high-risk age segments.
========================================================================
*/

-- 1. Rank customers within each age group by debt_ratio (use RANK() window function)
WITH age_groups AS (
    SELECT 
        id,
        debt_ratio,
        CASE 
            WHEN age BETWEEN 20 AND 30 THEN '20-30'
            WHEN age BETWEEN 31 AND 40 THEN '31-40'
            WHEN age BETWEEN 41 AND 50 THEN '41-50'
            WHEN age BETWEEN 51 AND 60 THEN '51-60'
            WHEN age > 60 THEN '60+'
            ELSE 'Unknown'
        END AS age_group
    FROM customers
)
SELECT 
    id,
    age_group,
    debt_ratio,
    RANK() OVER (PARTITION BY age_group ORDER BY debt_ratio DESC) as debt_rank
FROM age_groups
ORDER BY age_group, debt_rank;

-- 2. Calculate running total of defaulted customers ordered by age
SELECT 
    id,
    age,
    serious_dlqin2yrs,
    SUM(serious_dlqin2yrs) OVER (ORDER BY age ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total_defaults
FROM customers
WHERE serious_dlqin2yrs = 1;

-- 3. Find the top 3 highest-risk age groups based on default rate
WITH group_risk AS (
    SELECT 
        CASE 
            WHEN age BETWEEN 20 AND 30 THEN '20-30'
            WHEN age BETWEEN 31 AND 40 THEN '31-40'
            WHEN age BETWEEN 41 AND 50 THEN '41-50'
            WHEN age BETWEEN 51 AND 60 THEN '51-60'
            WHEN age > 60 THEN '60+'
            ELSE 'Unknown'
        END AS age_group,
        AVG(serious_dlqin2yrs) AS default_rate,
        COUNT(*) AS group_size
    FROM customers
    GROUP BY age_group
)
SELECT 
    age_group,
    default_rate,
    group_size
FROM group_risk
WHERE age_group != 'Unknown'
ORDER BY default_rate DESC
LIMIT 3;
