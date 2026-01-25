-- Fact: one row per user-course-week for survival-style retention (based on last_event_date)
-- Interpretation: retained_to_week_n means last_event_date is on/after start_date + 7*n
CREATE OR REPLACE VIEW analytics.fct_user_course_weekly_retention AS
WITH params AS (
  -- Choose a sensible max horizon for retention curves (edit if you want)
  SELECT 16::int AS max_weeks
),
cohorts AS (
  SELECT
    f.user_id,
    f.course_id,
    f.start_date,
    f.last_event_date,

    -- Cohort bucket: week of start_date (Monday-based in Postgres date_trunc)
    date_trunc('week',f.start_date)::date AS cohort_week_start

  FROM analytics.fct_user_course_lifecycle f
  WHERE f.start_date IS NOT NULL
),
weeks AS (
  -- Generate week numbers 0..max_weeks for each user-course row
  SELECT
    c.user_id,
    c.course_id,
    c.start_date,
    c.last_event_date,
    c.cohort_week_start,
    gs.week_number
  FROM cohorts c
  CROSS JOIN params p
  CROSS JOIN LATERAL generate_series(0,p.max_weeks) AS gs(week_number)
)
SELECT
  user_id,
  course_id,
  cohort_week_start,
  week_number,

  -- Survival retention: still active by the end of week_number
  CASE
    WHEN last_event_date IS NULL THEN false
    WHEN last_event_date >= (start_date + (week_number * 7)) THEN true
    ELSE false
  END AS is_retained_to_week

FROM weeks;

select * from analytics.fct_user_course_weekly_retention limit 10