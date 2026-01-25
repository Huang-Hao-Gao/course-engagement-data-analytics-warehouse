-- Retention sanity checks for survival-style retention
-- Expectation: for a given course+cohort, retention_rate should be non-increasing with week_number
WITH r AS (
  SELECT
    course_id,
    cohort_week_start,
    week_number,
    retention_rate
  FROM marts.retention_weekly_by_course_cohort
),
violations AS (
  SELECT
    course_id,
    cohort_week_start,
    week_number,
    retention_rate,
    lag(retention_rate) OVER (PARTITION BY course_id,cohort_week_start ORDER BY week_number) AS prev_retention_rate
  FROM r
),
bad AS (
  SELECT *
  FROM violations
  WHERE prev_retention_rate IS NOT NULL AND retention_rate>prev_retention_rate
)
SELECT
  count(*) AS violating_rows,
  -- show a few examples if there are any
  (SELECT count(DISTINCT course_id) FROM bad) AS courses_affected,
  (SELECT count(DISTINCT cohort_week_start) FROM bad) AS cohorts_affected
FROM bad;
