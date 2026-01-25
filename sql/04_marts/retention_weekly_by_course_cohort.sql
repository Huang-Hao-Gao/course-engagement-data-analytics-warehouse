-- Weekly retention curves by course and start-week cohort (survival-style)
CREATE OR REPLACE VIEW marts.retention_weekly_by_course_cohort AS
WITH base AS (
  SELECT
    r.course_id,
    r.cohort_week_start,
    r.week_number,
    r.user_id,
    r.is_retained_to_week
  FROM analytics.fct_user_course_weekly_retention r
),
cohort_sizes AS (
  -- Cohort size is week 0 population
  SELECT
    course_id,
    cohort_week_start,
    count(DISTINCT user_id) AS cohort_size
  FROM base
  WHERE week_number=0
  GROUP BY course_id,cohort_week_start
)
SELECT
  b.course_id,
  b.cohort_week_start,
  b.week_number,

  cs.cohort_size,
  count(DISTINCT b.user_id) FILTER (WHERE b.is_retained_to_week) AS retained_users,
  (count(DISTINCT b.user_id) FILTER (WHERE b.is_retained_to_week))::numeric / nullif(cs.cohort_size,0) AS retention_rate

FROM base b
JOIN cohort_sizes cs
  ON cs.course_id=b.course_id
  AND cs.cohort_week_start=b.cohort_week_start
GROUP BY
  b.course_id,
  b.cohort_week_start,
  b.week_number,
  cs.cohort_size;


SELECT course_id, cohort_week_start,week_number,retention_rate
FROM marts.retention_weekly_by_course_cohort
where course_id = 'MITx/3.091x/2013_Spring' and cohort_week_start = DATE '2013-01-28'
ORDER BY course_id, cohort_week_start,week_number;

