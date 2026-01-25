-- Query 1: Total rows and distinct counts
SELECT 
  count(*) AS total_records,
  count(DISTINCT userid_di) AS distinct_users,
  count(DISTINCT course_id) AS distinct_courses
FROM raw.course_user_engagement;

-- Query 2: Core metrics from KPI table
SELECT * FROM marts.kpi_summary;

-- Query 3: Engagement band certification rates
SELECT engagement_band, 
       count(*) AS learners,
       avg(certification_rate)
FROM marts.engagement_bands_and_outcomes
GROUP BY engagement_band
ORDER BY engagement_band;

-- Query 4: Get min/max for retention drop-off verification
SELECT week_number, 
       count(DISTINCT user_id) AS users_in_week,
       avg(is_retained_to_week::int)::numeric(10,4) AS retention_rate
FROM analytics.fct_user_course_weekly_retention
GROUP BY week_number
ORDER BY week_number
LIMIT 5;