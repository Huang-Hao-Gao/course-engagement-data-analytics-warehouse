-- Churn and outcomes by course: helps identify "good" vs "problem" courses
CREATE OR REPLACE VIEW marts.churn_summary_by_course AS
SELECT
  f.course_id,
  c.course_org,
  c.course_code,
  c.course_run,
  c.course_start_date,
  c.course_end_date,

  count(*) AS learners,
  avg(f.is_activated::int)::numeric(10,4) AS activation_rate,
  avg(coalesce(f.is_certified,false)::int)::numeric(10,4) AS certification_rate,
  avg(f.is_churned::int)::numeric(10,4) AS churn_rate,

  -- Behaviour signals
  percentile_cont(0.5) WITHIN GROUP (ORDER BY f.n_days_active) FILTER (WHERE f.is_activated) AS median_active_days_activated,
  percentile_cont(0.5) WITHIN GROUP (ORDER BY f.n_events) FILTER (WHERE f.is_activated) AS median_events_activated,

  -- Churn type mix for narrative insight
  avg((f.churn_type='no_activity')::int)::numeric(10,4) AS share_no_activity,
  avg((f.churn_type='early_churn')::int)::numeric(10,4) AS share_early_churn,
  avg((f.churn_type='engaged_no_cert')::int)::numeric(10,4) AS share_engaged_no_cert

FROM analytics.fct_user_course_lifecycle f
JOIN analytics.dim_courses c ON c.course_id=f.course_id
GROUP BY
  f.course_id,
  c.course_org,
  c.course_code,
  c.course_run,
  c.course_start_date,
  c.course_end_date;


SELECT *
FROM marts.churn_summary_by_course
ORDER BY learners DESC
LIMIT 20;