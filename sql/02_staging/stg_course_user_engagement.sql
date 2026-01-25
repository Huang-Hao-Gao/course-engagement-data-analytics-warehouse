-- Staging view: standardise names, parse dates, normalise flags, cast metrics safely
CREATE VIEW stg.stg_course_user_engagement AS
WITH src AS (
  -- Trim whitespace so parsing/casts are reliable
  SELECT
    btrim(index) AS index_raw,
    btrim(random) AS random_raw,
    btrim(course_id) AS course_id_raw,
    btrim(userid_di) AS user_id_raw,
    btrim(registered) AS registered_raw,
    btrim(viewed) AS viewed_raw,
    btrim(explored) AS explored_raw,
    btrim(certified) AS certified_raw,
    btrim(final_cc_cname_di) AS country_raw,
    btrim(loe_di) AS loe_raw,
    btrim(yob) AS yob_raw,
    btrim(gender) AS gender_raw,
    btrim(grade) AS grade_raw,
    btrim(start_time_di) AS start_time_raw,
    btrim(last_event_di) AS last_event_time_raw,
    btrim(nevents) AS nevents_raw,
    btrim(ndays_act) AS ndays_act_raw,
    btrim(nplay_video) AS nplay_video_raw,
    btrim(nchapter) AS nchapter_raw,
    btrim(nforum_posts) AS nforum_posts_raw,
    btrim(roles) AS roles_raw,
    btrim(incomplete_flag) AS incomplete_flag_raw
  FROM raw.course_user_engagement
),
typed AS (
  SELECT
    -- Keys
    NULLIF(index_raw,'')::int AS row_index,
    NULLIF(random_raw,'')::numeric AS random_value,
    NULLIF(course_id_raw,'') AS course_id,
    NULLIF(user_id_raw,'') AS user_id,

    -- Flags: accept 0/1 and true/false variants
    CASE
      WHEN lower(NULLIF(registered_raw,'')) IN ('1','true','t','yes','y') THEN true
      WHEN lower(NULLIF(registered_raw,'')) IN ('0','false','f','no','n') THEN false
      ELSE null
    END AS is_registered,
    CASE
      WHEN lower(NULLIF(viewed_raw,'')) IN ('1','true','t','yes','y') THEN true
      WHEN lower(NULLIF(viewed_raw,'')) IN ('0','false','f','no','n') THEN false
      ELSE null
    END AS is_viewed,
    CASE
      WHEN lower(NULLIF(explored_raw,'')) IN ('1','true','t','yes','y') THEN true
      WHEN lower(NULLIF(explored_raw,'')) IN ('0','false','f','no','n') THEN false
      ELSE null
    END AS is_explored,
    CASE
      WHEN lower(NULLIF(certified_raw,'')) IN ('1','true','t','yes','y') THEN true
      WHEN lower(NULLIF(certified_raw,'')) IN ('0','false','f','no','n') THEN false
      ELSE null
    END AS is_certified,

    -- Attributes
    NULLIF(country_raw,'') AS country,
    NULLIF(loe_raw,'') AS level_of_education,
    CASE
      WHEN NULLIF(yob_raw,'') ~ '^\d{4}$' THEN yob_raw::int
      ELSE null
    END AS year_of_birth,
    NULLIF(gender_raw,'') AS gender,
    NULLIF(grade_raw,'') AS grade,
    NULLIF(roles_raw,'') AS roles,

    -- Dates: source is M/D/YYYY; parse to date then cast to timestamp (no timezone)
    CASE
      WHEN start_time_raw IS NULL OR start_time_raw='' THEN null
      WHEN start_time_raw ~ '^\d{1,2}/\d{1,2}/\d{4}$' THEN to_date(start_time_raw,'MM/DD/YYYY')::timestamp
      ELSE null
    END AS start_time,
    CASE
      WHEN last_event_time_raw IS NULL OR last_event_time_raw='' THEN null
      WHEN last_event_time_raw ~ '^\d{1,2}/\d{1,2}/\d{4}$' THEN to_date(last_event_time_raw,'MM/DD/YYYY')::timestamp
      ELSE null
    END AS last_event_time,

    -- Metrics: accept integers stored like "9 telling
    CASE
      WHEN NULLIF(nevents_raw,'') ~ '^\d+(\.\d+)?$' THEN floor(nevents_raw::numeric)::int
      ELSE null
    END AS n_events,
    CASE
      WHEN NULLIF(ndays_act_raw,'') ~ '^\d+(\.\d+)?$' THEN floor(ndays_act_raw::numeric)::int
      ELSE null
    END AS n_days_active,
    CASE
      WHEN NULLIF(nplay_video_raw,'') ~ '^\d+(\.\d+)?$' THEN floor(nplay_video_raw::numeric)::int
      ELSE null
    END AS n_video_plays,
    CASE
      WHEN NULLIF(nchapter_raw,'') ~ '^\d+(\.\d+)?$' THEN floor(nchapter_raw::numeric)::int
      ELSE null
    END AS n_chapters,
    CASE
      WHEN NULLIF(nforum_posts_raw,'') ~ '^\d+(\.\d+)?$' THEN floor(nforum_posts_raw::numeric)::int
      ELSE null
    END AS n_forum_posts,

    -- Incomplete: normalise to boolean
    CASE
      WHEN lower(NULLIF(incomplete_flag_raw,'')) IN ('1','true','t','yes','y') THEN true
      WHEN lower(NULLIF(incomplete_flag_raw,'')) IN ('0','false','f','no','n') THEN false
      ELSE null
    END AS is_incomplete
  FROM src
)
-- Convenience date columns for cohorts and retention windows
SELECT
  *,
  start_time::date AS start_date,
  last_event_time::date AS last_event_date
FROM typed;
SELECT * FROM stg.stg_course_user_engagement limit 20