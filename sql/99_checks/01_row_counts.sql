-- Row count reconciliation across layers and expected retention expansion
WITH counts AS (
  SELECT 'raw' AS layer, count(*)::bigint AS rows FROM raw.course_user_engagement
  UNION ALL
  SELECT 'stg' AS layer, count(*)::bigint AS rows FROM stg.stg_course_user_engagement
  UNION ALL
  SELECT 'lifecycle' AS layer, count(*)::bigint AS rows FROM analytics.fct_user_course_lifecycle
),
params AS (
  -- Update this if you change retention horizon in analytics.fct_user_course_weekly_retention
  SELECT 16::int AS max_weeks
),
expected AS (
  SELECT
    (SELECT rows FROM counts WHERE layer='lifecycle') AS lifecycle_rows,
    (SELECT rows FROM counts WHERE layer='raw') AS raw_rows,
    (SELECT rows FROM counts WHERE layer='stg') AS stg_rows,
    (SELECT max_weeks FROM params) AS max_weeks,
    ((SELECT rows FROM counts WHERE layer='lifecycle') * ((SELECT max_weeks FROM params) + 1))::bigint AS expected_retention_rows,
    (SELECT count(*)::bigint FROM analytics.fct_user_course_weekly_retention) AS actual_retention_rows
)
SELECT
  raw_rows,
  stg_rows,
  lifecycle_rows,
  (raw_rows=stg_rows) AS raw_equals_stg,
  (stg_rows=lifecycle_rows) AS stg_equals_lifecycle,
  max_weeks,
  expected_retention_rows,
  actual_retention_rows,
  (expected_retention_rows=actual_retention_rows) AS retention_rows_match
FROM expected;
