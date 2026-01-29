# SQL Analytics Warehouse for Online Course Engagement

## Project Overview

This project is a SQL-based analytics case study analysing user engagement, retention, and course completion for an online learning platform.

The dataset represents learner activity across multiple online courses, including enrolment dates, engagement metrics, and certification outcomes. The project is framed as simulated internal analytics work for an online education platform similar to Coursera or edX.

The objective of the analysis is to understand how learners engage with courses over time, how long they remain active, and which patterns of behaviour are associated with successful course completion. The project is intended to support learning experience teams in evaluating course performance and learner behaviour.


---

## Business Question

**How can we increase the number of learners who complete our course?**

### Key Findings

- A high proportion of learners activate initially, but relatively few go on to complete courses.
- Engagement behaviour appears highly skewed, with many learners disengaging early and a smaller group remaining active for long periods.
- Certification is strongly associated with sustained engagement rather than short bursts of activity.
- Retention patterns vary meaningfully across courses, suggesting differences in course design or learner intent.

### How the analysis breaks down this question

To answer the core business question, the analysis investigates four specific areas:

1. **How many learners meaningfully engage with a course after enrolling?**  
   *Impact: Identifies the activation bottleneck and whether the issue is enrolment drop-off or design-related disengagement.*

2. **How does engagement depth relate to course completion and certification?**  
   *Impact: Reveals whether engagement is predictive of outcomes, helping prioritise interventions on high-intent learners.*

3. **How long do learners typically remain active after starting a course?**  
   *Impact: Pinpoints critical drop-off windows where learners churn, informing intervention timing.*

4. **How do engagement and retention patterns vary across courses and cohorts?**  
   *Impact: Highlights which courses over- or under-perform, enabling course-specific improvements.*

---

## Dataset

- **Source:** Public online course user engagement dataset [Link to Kaggle Dataset](https://www.kaggle.com/datasets/thedevastator/online-course-user-engagement-data)
- **Scope:** User-level engagement across multiple courses and course runs
- **Format:** Single CSV file ingested into PostgreSQL

The dataset required cleaning and validation before analysis, including type standardisation, date parsing, and normalisation of engagement flags.

---

## Tools Used

- PostgreSQL
- SQL (CTEs, window functions, cohort logic)
- VS Code with SQLTools
- GitHub for version control

---

## Approach & Rigor

**Built with 6 automated data quality checks** to ensure analytical reliability:
- Row count validation across all layers
- Key uniqueness verification
- Null and domain constraint checks
- Date logic validation
- Metric sanity checks
- Retention-specific validation

## Data Cleaning and Preparation

The data was modelled using a layered analytics warehouse structure to reflect real-world analytics workflows.

### Key steps

- Preserved the raw dataset exactly as received to ensure reproducibility
- Cleaned and standardised data in a staging layer:
  - Parsed dates from inconsistent formats
  - Converted engagement metrics stored as text into numeric fields
  - Normalised boolean flags
- Built analytics models on top of cleaned data to define:
  - User–course lifecycles
  - Engagement and activation logic
  - Churn and completion outcomes
- Added data quality checks to validate row counts, key uniqueness, date logic, and metric consistency

This approach ensures that analytical outputs are reliable and auditable.

---

## Analytical Approach

Each row in the analytics layer represents a **single learner’s lifecycle within a single course**.

Courses are treated as subscription-like experiences with:
- a start date
- an observed end of activity
- an outcome (certified or not)

Retention is measured using a **survival-style approach**, based on how long learners remain active after starting a course. Because the dataset only includes start and last activity dates, retention reflects *engagement longevity* rather than week-by-week activity.

This limitation is explicitly documented and handled conservatively.

---

## Key Outputs and Visual Evidence

Below are selected outputs generated directly from SQL models.

### Overall platform KPIs

![KPI Summary](screenshots/kpi-summary.png)

Key metrics:
- Activation rate: ~85%
- Certification rate: ~3%
- Churn rate (non-certification by course end): ~97% (1 - Certification Rate)
- Median active days among activated learners: 2

---

### Weekly retention (example course)

![Weekly Retention](screenshots/weekly-retention.png)

This table shows survival-style retention for a single course cohort, illustrating sharp early drop-off followed by a smaller group of long-running learners.

---

### Engagement depth vs outcomes

![Engagement Bands](screenshots/engagement-bands.png)

Learners with higher sustained engagement show markedly higher certification rates, suggesting a strong relationship between early and ongoing activity and successful outcomes.

---

## Project Value

This project demonstrates the ability to:

- Design and implement a SQL-based analytics warehouse
- Model user lifecycles, retention, and churn using imperfect real-world data
- Apply cohort and survival analysis concepts appropriately
- Build reproducible, well-structured analytical workflows
- Communicate analytical results clearly and honestly

---

## Repository Contents

- `data/` – Raw source dataset
- `sql/`
  - `00_admin/` – Schema and setup
  - `01_raw/` – Raw data ingestion
  - `02_staging/` – Cleaning and standardisation
  - `03_analytics/` – Facts and dimensions
  - `04_marts/` – Final analytical outputs
  - `99_checks/` – Data quality and sanity checks
- `screenshots/` – Visual evidence of key outputs
- `README.md` – Project overview and findings