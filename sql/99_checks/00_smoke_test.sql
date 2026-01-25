-- Smoke test: confirm core objects are queryable
SELECT 'raw.course_user_engagement' AS object, count(*) AS row_count FROM raw.course_user_engagement
UNION ALL
SELECT 'stg.stg_course_user_engagement' AS object, count(*) AS row_count FROM stg.stg_course_user_engagement
UNION ALL
SELECT 'analytics.dim_users' AS object, count(*) AS row_count FROM analytics.dim_users
UNION ALL
SELECT 'analytics.dim_courses' AS object, count(*) AS row_count FROM analytics.dim_courses
UNION ALL
SELECT 'analytics.fct_user_course_lifecycle' AS object, count(*) AS row_count FROM analytics.fct_user_course_lifecycle
UNION ALL
SELECT 'analytics.fct_user_course_weekly_retention' AS object, count(*) AS row_count FROM analytics.fct_user_course_weekly_retention
UNION ALL
SELECT 'marts.kpi_summary' AS object, count(*) AS row_count FROM marts.kpi_summary
UNION ALL
SELECT 'marts.churn_summary_by_course' AS object, count(*) AS row_count FROM marts.churn_summary_by_course
UNION ALL
SELECT 'marts.retention_weekly_by_course_cohort' AS object, count(*) AS row_count FROM marts.retention_weekly_by_course_cohort
UNION ALL
SELECT 'marts.engagement_bands_and_outcomes' AS object, count(*) AS row_count FROM marts.engagement_bands_and_outcomes;
