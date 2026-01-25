-- Metric sanity checks to catch broken casts or inconsistent derivations
WITH base AS (
  SELECT *
  FROM analytics.fct_user_course_lifecycle
),
checks AS (
  -- Activated users should have some engagement signal (by our activation definition)
  SELECT 'activated but zero engagement signals' AS check_name, count(*) AS bad_rows
  FROM base
  WHERE is_activated=true
    AND coalesce(is_viewed,false)=false
    AND coalesce(is_explored,false)=false
    AND coalesce(n_events,0)=0
    AND coalesce(n_days_active,0)=0
    AND coalesce(n_video_plays,0)=0
    AND coalesce(n_chapters,0)=0
    AND coalesce(n_forum_posts,0)=0
  UNION ALL
  -- Certified users should normally be activated; if not, flag it
  SELECT 'certified but not activated' AS check_name, count(*) AS bad_rows
  FROM base
  WHERE coalesce(is_certified,false)=true AND is_activated=false
  UNION ALL
  -- Churn types should cover all rows (no null churn_type)
  SELECT 'churn_type is null' AS check_name, count(*) AS bad_rows
  FROM base
  WHERE churn_type IS NULL
)
SELECT check_name,bad_rows
FROM checks
ORDER BY bad_rows DESC,check_name;
