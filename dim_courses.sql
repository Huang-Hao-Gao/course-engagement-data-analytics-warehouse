-- Course dimension: one row per course with derived lifecycle context
CREATE OR REPLACE VIEW analytics.dim_courses AS
SELECT
  course_id,

  -- Course identifier breakdown for readability
  split_part(course_id,'/',1) AS course_org,
  split_part(course_id,'/',2) AS course_code,
  split_part(course_id,'/',3) AS course_run,

  -- Observed lifecycle boundaries
  min(start_date) AS course_start_date,
  max(last_event_date) AS course_end_date,

  -- Approximate course duration in days
  (max(last_event_date) - min(start_date)) AS course_duration_days

FROM stg.stg_course_user_engagement
WHERE course_id IS NOT NULL
GROUP BY course_id;
