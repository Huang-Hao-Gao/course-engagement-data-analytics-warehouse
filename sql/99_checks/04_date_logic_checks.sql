-- Date logic checks for lifecycle integrity
WITH base AS (
  SELECT *
  FROM analytics.fct_user_course_lifecycle
),
course AS (
  SELECT *
  FROM analytics.dim_courses
),
checks AS (
  SELECT 'last_event_date before start_date' AS check_name, count(*) AS bad_rows
  FROM base
  WHERE start_date IS NOT NULL AND last_event_date IS NOT NULL AND last_event_date<start_date
  UNION ALL
  SELECT 'course_end_date before course_start_date' AS check_name, count(*) AS bad_rows
  FROM course
  WHERE course_start_date IS NOT NULL AND course_end_date IS NOT NULL AND course_end_date<course_start_date
  UNION ALL
  SELECT 'days_to_last_event negative' AS check_name, count(*) AS bad_rows
  FROM base
  WHERE days_to_last_event IS NOT NULL AND days_to_last_event<0
  UNION ALL
  SELECT 'active_span_days non-positive' AS check_name, count(*) AS bad_rows
  FROM base
  WHERE active_span_days IS NOT NULL AND active_span_days<=0
)
SELECT check_name,bad_rows
FROM checks
ORDER BY bad_rows DESC,check_name;
