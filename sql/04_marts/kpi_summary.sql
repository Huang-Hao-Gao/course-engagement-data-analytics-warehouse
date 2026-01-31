-- KPI summary: top-level product metrics for the README
CREATE OR REPLACE VIEW marts.kpi_summary AS
WITH base AS (
  SELECT *
  FROM intermediate.fct_user_course_lifecycle
)
SELECT
  count(*) AS user_course_rows,
  count(DISTINCT user_id) AS users,
  count(DISTINCT course_id) AS courses,

  -- Activation: any meaningful engagement
  avg(is_activated::int)::numeric(10,4) AS activation_rate,

  -- Certification: primary outcome
  avg(coalesce(is_certified,false)::int)::numeric(10,4) AS certification_rate,

  -- Churn as defined: course ended without certification
  avg(is_churned::int)::numeric(10,4) AS churn_rate,

  -- Engagement central tendency among activated learners
  percentile_cont(0.5) WITHIN GROUP (ORDER BY n_days_active) FILTER (WHERE is_activated) AS median_active_days_activated,
  percentile_cont(0.5) WITHIN GROUP (ORDER BY n_events) FILTER (WHERE is_activated) AS median_events_activated,

  -- Share with no observed activity window (never generated a last_event_date)
  avg((last_event_date IS NULL)::int)::numeric(10,4) AS share_no_last_event_date

FROM base;

SELECT * FROM marts.kpi_summary;