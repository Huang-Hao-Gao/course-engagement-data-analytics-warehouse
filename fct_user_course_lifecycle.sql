-- Fact: one row per user-course with lifecycle metrics, activation and churn flags
CREATE OR REPLACE VIEW analytics.fct_user_course_lifecycle AS
WITH base AS (
  SELECT
    s.user_id,
    s.course_id,

    -- Raw lifecycle dates
    s.start_date,
    s.last_event_date,

    -- Source flags and engagement metrics
    s.is_registered,
    s.is_viewed,
    s.is_explored,
    s.is_certified,
    s.is_incomplete,
    s.n_events,
    s.n_days_active,
    s.n_video_plays,
    s.n_chapters,
    s.n_forum_posts,

    -- Course context needed for churn definition
    c.course_start_date,
    c.course_end_date,
    c.course_duration_days

  FROM stg.stg_course_user_engagement s
  JOIN analytics.dim_courses c ON c.course_id=s.course_id
  WHERE s.user_id IS NOT NULL AND s.course_id IS NOT NULL
),
derived AS (
  SELECT
    b.*,

    -- Activation: any meaningful sign of engagement
    (
      coalesce(b.is_viewed,false)
      OR coalesce(b.is_explored,false)
      OR coalesce(b.n_events,0)>0
      OR coalesce(b.n_days_active,0)>0
      OR coalesce(b.n_video_plays,0)>0
      OR coalesce(b.n_chapters,0)>0
      OR coalesce(b.n_forum_posts,0)>0
    ) AS is_activated,

    -- Days between start and last observed activity (null if no last_event)
    CASE
      WHEN b.last_event_date IS NULL OR b.start_date IS NULL THEN null
      ELSE (b.last_event_date - b.start_date)
    END AS days_to_last_event,

    -- Span of time user was active in this course (inclusive)
    CASE
      WHEN b.last_event_date IS NULL OR b.start_date IS NULL THEN null
      ELSE (b.last_event_date - b.start_date) + 1
    END AS active_span_days,

    -- Approx number of weeks "covered" by the observed activity window (survival style)
    CASE
      WHEN b.last_event_date IS NULL OR b.start_date IS NULL THEN null
      ELSE ceil(((b.last_event_date - b.start_date) + 1)::numeric / 7.0)::int
    END AS active_weeks_observed

  FROM base b
)
SELECT
  d.*,

  -- Churn: course ended (as observed) and the learner did not certify
  (coalesce(d.is_certified,false)=false AND d.course_end_date IS NOT NULL) AS is_churned,

  -- Simple churn type buckets for more insightful breakdowns
  CASE
    WHEN coalesce(d.is_certified,false)=true THEN 'certified'
    WHEN d.last_event_date IS NULL THEN 'no_activity'
    WHEN d.start_date IS NOT NULL AND d.last_event_date < d.start_date + 7 THEN 'early_churn'
    ELSE 'engaged_no_cert'
  END AS churn_type

FROM derived d;


-- Lifecycle fact should match staging grain (user-course rows)
SELECT count(*) FROM stg.stg_course_user_engagement;
SELECT count(*) FROM analytics.fct_user_course_lifecycle;

-- Weekly retention expands rows by (max_weeks+1)
SELECT count(*) FROM analytics.fct_user_course_weekly_retention;

-- Spot-check a single course’s retention curve
SELECT cohort_week_start,week_number,avg(is_retained_to_week::int) AS retention_rate
FROM analytics.fct_user_course_weekly_retention
WHERE course_id='HarvardX/CS50x/2012'
GROUP BY 1,2
ORDER BY 1,2;
