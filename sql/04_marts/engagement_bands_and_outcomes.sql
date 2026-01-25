-- Engagement bands: show how sustained engagement relates to certification and churn
CREATE OR REPLACE VIEW marts.engagement_bands_and_outcomes AS
WITH base AS (
  SELECT
    course_id,
    is_activated,
    coalesce(is_certified,false) AS is_certified,
    is_churned,
    coalesce(n_days_active,0) AS n_days_active,
    coalesce(n_events,0) AS n_events,
    coalesce(n_chapters,0) AS n_chapters,
    coalesce(n_forum_posts,0) AS n_forum_posts
  FROM analytics.fct_user_course_lifecycle
),
banded AS (
  SELECT
    *,
    CASE
      WHEN is_activated=false THEN 'not_activated'
      WHEN n_days_active=0 THEN '0_days'
      WHEN n_days_active BETWEEN 1 AND 2 THEN '1_2_days'
      WHEN n_days_active BETWEEN 3 AND 7 THEN '3_7_days'
      WHEN n_days_active BETWEEN 8 AND 14 THEN '8_14_days'
      ELSE '15_plus_days'
    END AS engagement_band
  FROM base
)
SELECT
  course_id,
  engagement_band,
  count(*) AS learners,
  avg(is_certified::int)::numeric(10,4) AS certification_rate,
  avg(is_churned::int)::numeric(10,4) AS churn_rate,
  avg(n_events)::numeric(12,2) AS avg_events,
  avg(n_chapters)::numeric(12,2) AS avg_chapters,
  avg(n_forum_posts)::numeric(12,2) AS avg_forum_posts
FROM banded
GROUP BY course_id,engagement_band;


SELECT *
FROM marts.engagement_bands_and_outcomes
ORDER BY engagement_band;