# 📈 DebtSignal — End-to-End Borrower Risk Analytics Pipeline

> **End-to-End Borrower Risk Analytics Pipeline**

## 📖 Project Overview
A lending company needs to proactively identify borrowers likely to default. This project builds an end-to-end SQL analytics pipeline using real-world credit data to segment customers by risk, analyze delinquency patterns, and surface data-driven insights for credit risk teams.

## 🛠️ Tech Stack
- **Database:** PostgreSQL
- **Language:** Python, SQL
- **Libraries:** pandas, psycopg2

## 📊 Dataset
The raw dataset was sourced directly from Kaggle's [Give Me Some Credit](https://www.kaggle.com/c/GiveMeSomeCredit) competition. 
It contains **150,000 anonymized borrower records** featuring core financial attributes including debt ratio, monthly income, and historical delinquency performance.

## 📂 Project Structure
```text
credit-risk-analytics/
├── data/
├── sql/
│   ├── 02_risk_segmentation.sql
│   ├── 03_delinquency_analysis.sql
│   ├── 04_dti_analysis.sql
│   └── 05_cohort_analysis.sql
├── scripts/
│   └── load_data.py
├── outputs/
└── README.md
```

## 💡 Key Insights
Through our SQL-driven analysis, we generated the following operational alerts for the underwriting team:
- 🚨 **7.61% of borrowers fall in the High Risk segment**, representing 11,414 potential defaulters
- 📉 **Customers aged 20–30 exhibit the highest default rate at 11.56%**, nearly 4x that of the 60+ age group (3.0%)
- 💵 **Below-median income customers default at 7.57%** vs 5.35% for above-median earners
- 💳 **High DTI borrowers (debt ratio > 0.6) show a 7.57% default rate** compared to 5.87% for Low DTI customers

## 🔍 SQL Analyses
The analytical backbone of the project depends on four distinct SQL workflows:

*   **`02_risk_segmentation.sql`**: Configured advanced risk segmentation logic utilizing conditional `CASE WHEN` evaluations; generated a scalable PostgreSQL `VIEW` for downstream reporting.
*   **`03_delinquency_analysis.sql`**: Conducted comprehensive age group analysis, ranked the top late-payment offenders, and compared default frequencies against median monthly income ceilings.
*   **`04_dti_analysis.sql`**: Utilized Common Table Expressions (`CTE`s) to bucket users strictly by calculated DTI profiles to surface aggregate default variations.
*   **`05_cohort_analysis.sql`**: Executed advanced cohort aggregation using Window Functions (`RANK()` and running totals) to analyze cumulative borrower risk ordered temporally by age brackets.

## 🚀 How to Run

1. **Prepare the local environment:**
   Ensure the `cs-training.csv` is correctly placed inside the `data/` directory.

2. **Install prerequisite libraries:**
   ```bash
   pip install pandas psycopg2-binary
   ```

3. **Ingest data to PostgreSQL:**
   Run the Python ETL script to clean missing variables (fillna median), coerce column terminology, and build the database table.
   ```bash
   python scripts/load_data.py
   ```

4. **Execute Analytical Scripts:**
   Connect to your database via pgAdmin, `psql`, or a VSCode database extension, and run each script sequentially inside the `sql/` folder to generate the actionable analytics!

---

## 👨‍💻 Author
**Bhavya Singla** | Data Analyst  
📧 [bhavyasingla009@gmail.com](mailto:bhavyasingla009@gmail.com)  
🔗 [linkedin.com/in/bhavyasingla9](https://www.linkedin.com/in/bhavyasingla9)
