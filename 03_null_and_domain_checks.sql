-- Null checks and basic domain sanity checks
WITH base AS (
  SELECT *
  FROM analytics.fct_user_course_lifecycle
),
user_attrs AS (
  SELECT *
  FROM analytics.dim_users
),
checks AS (
  SELECT 'lifecycle user_id null' AS check_name, count(*) AS bad_rows
  FROM base
  WHERE user_id IS NULL
  UNION ALL
  SELECT 'lifecycle course_id null' AS check_name, count(*) AS bad_rows
  FROM base
  WHERE course_id IS NULL
  UNION ALL
  SELECT 'lifecycle start_date null' AS check_name, count(*) AS bad_rows
  FROM base
  WHERE start_date IS NULL
  UNION ALL
  SELECT 'dim_users user_id null' AS check_name, count(*) AS bad_rows
  FROM user_attrs
  WHERE user_id IS NULL
  UNION ALL
  -- If year_of_birth exists, it should be plausible (wide bounds)
  SELECT 'dim_users year_of_birth out of range' AS check_name, count(*) AS bad_rows
  FROM user_attrs
  WHERE year_of_birth IS NOT NULL AND (year_of_birth<1900 OR year_of_birth>2015)
  UNION ALL
  -- Engagement metrics should never be negative
  SELECT 'lifecycle negative engagement metric' AS check_name, count(*) AS bad_rows
  FROM base
  WHERE coalesce(n_events,0)<0 OR coalesce(n_days_active,0)<0 OR coalesce(n_video_plays,0)<0 OR coalesce(n_chapters,0)<0 OR coalesce(n_forum_posts,0)<0
)
SELECT check_name,bad_rows
FROM checks
ORDER BY bad_rows DESC,check_name;
