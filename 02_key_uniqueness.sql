-- Key uniqueness checks for expected grains
WITH checks AS (
  SELECT
    'analytics.dim_users user_id unique' AS check_name,
    (SELECT count(*) FROM analytics.dim_users) AS total_rows,
    (SELECT count(*) FROM (SELECT user_id FROM analytics.dim_users GROUP BY 1 HAVING count(*)>1) d) AS duplicate_keys
  UNION ALL
  SELECT
    'analytics.dim_courses course_id unique' AS check_name,
    (SELECT count(*) FROM analytics.dim_courses) AS total_rows,
    (SELECT count(*) FROM (SELECT course_id FROM analytics.dim_courses GROUP BY 1 HAVING count(*)>1) d) AS duplicate_keys
  UNION ALL
  SELECT
    'fct_user_course_lifecycle (user_id,course_id) unique' AS check_name,
    (SELECT count(*) FROM analytics.fct_user_course_lifecycle) AS total_rows,
    (SELECT count(*) FROM (
      SELECT user_id,course_id
      FROM analytics.fct_user_course_lifecycle
      GROUP BY 1,2
      HAVING count(*)>1
    ) d) AS duplicate_keys
  UNION ALL
  SELECT
    'weekly_retention (user_id,course_id,week_number) unique' AS check_name,
    (SELECT count(*) FROM analytics.fct_user_course_weekly_retention) AS total_rows,
    (SELECT count(*) FROM (
      SELECT user_id,course_id,week_number
      FROM analytics.fct_user_course_weekly_retention
      GROUP BY 1,2,3
      HAVING count(*)>1
    ) d) AS duplicate_keys
)
SELECT
  check_name,
  total_rows,
  duplicate_keys,
  (duplicate_keys=0) AS pass
FROM checks;
